import Foundation

/// Class that allows sub window compositions in stacks, either horizontal or vertical
public class TermMultiWindow : TermWindow {
    
    /// The stacking type
    public enum StackType {
        case horizontal /// splits the terminal horizontally
        case vertical /// splits the terminal vertically
    }
    
    /// Generic error type for filtering
    /// TODO: expand on it
    public struct ConfigurationError : Error {
        
    }
    
    let subwindows : [TermWindow] /// subwindows for this window
    let stackType: StackType /// split type
    let ratios : [Float] /// original ratios asked by the caller
    var offsets : [Int] /// translation into character offsets
    
    /// function that translates and rounds ratios to offsets (to avoid code duplication)
    /// - Parameters:
    ///   - length: total width or height to split
    ///   - ratios: ratios to apply
    /// - Returns: the offsets
    static func offsetsFromRatios(length: Int, ratios: [Float]) -> [Int] {
        if ratios.isEmpty { return [] }
        
        let totalRatio = ratios.reduce(0.0) { $0+$1 } // not necessarily normalized
        let totalLength = Float(length)
        var currentlyUsed = 0
        
        var lengthes = [Int]()
        lengthes.append(0)
        currentlyUsed = Int((ratios[0] * totalLength)/totalRatio)
        lengthes.append(currentlyUsed)
        for i in 1..<(ratios.count - 1) {
            let value = Int((ratios[i] * totalLength)/totalRatio) + currentlyUsed
            lengthes.append(value)
            currentlyUsed += value
        }
//        if ratios.count > 2 {
//            lengthes.append(currentlyUsed)
//        }
        
        return lengthes
    }
    
    /// Convenience initializer to switch from variadic parameters to arrays
    /// - See init for details on the parameters
    convenience init(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws {
        try self.init(stack: stack, ratios: lrat, subs)
    }
    
    /// Standard initializer
    /// - Parameters:
    ///   - stack: vertical or horizontal
    ///   - ratios: the ratios to apply
    ///   - subs: the terminal windows that will compose this stack
    /// - Throws: if there is a mismatch in windows and ratios, of if a ratio is 0, or any other configuration error
    init(stack: StackType, ratios lrat: [Float], _ subs: [TermWindow]) throws {
        if subs.count < 2 { throw ConfigurationError() }
        if lrat.count != subs.count { throw ConfigurationError() }
        if lrat.contains(0.0) { throw ConfigurationError() }
        ratios = lrat
        stackType = stack
        subwindows = subs
        offsets = []
        super.init()
        let length = stackType == .horizontal ? self.cols : self.rows
        offsets = TermMultiWindow.offsetsFromRatios(length: length, ratios: ratios)
        for win in subwindows {
            win.embeddedIn = self
        }
        rowsDidChange()
        colsDidChange()
    }
    
    /// Publicly exposed initializer
    ///   - stack: vertical or horizontal
    ///   - ratios: the ratios to apply
    ///   - subs: the terminal windows that will compose this stack
    /// - Throws: if there is a mismatch in windows and ratios, of if a ratio is 0, or any other configuration error
    /// - Returns: a fully initialized stack of subwindows
    public static func setup(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws -> TermMultiWindow {
        return try TermMultiWindow(stack: stack, ratios: lrat, subs)
    }
    
    /// function to start displaying the graph
    public func start() {
        for win in subwindows {
            if let win = win as? StandardSeriesWindow {
                win.start()
            } else if let win = win as? TermMultiWindow {
                win.start()
            }
        }
    }
    
    /// function to stop displaying the graph
    public func stop() {
        for win in subwindows {
            if let win = win as? StandardSeriesWindow {
                win.stop()
            } else if let win = win as? TermMultiWindow {
                win.stop()
            }
        }
   }

    
    // MARK: -
    // MARK: overrides
    
    func sizeDidChange() {
        for idx in 0..<(subwindows.count-1) {
            if stackType == .horizontal {
                subwindows[idx].rows = self.rows
                subwindows[idx].cols = offsets[idx+1]-offsets[idx]
            } else {
                subwindows[idx].rows = offsets[idx+1]-offsets[idx]
                subwindows[idx].cols = self.cols
           }
        }
        if stackType == .horizontal {
            subwindows.last!.rows = self.rows
            subwindows.last!.cols = self.cols - offsets.last!
        } else {
            subwindows.last!.rows = self.rows - offsets.last!
            subwindows.last!.cols = self.cols
       }

    }
    
    override func rowsDidChange() {
        DispatchQueue.global().async { [self] in
            TermHandler.shared.lock()
            if stackType == .vertical {
                offsets = TermMultiWindow.offsetsFromRatios(length: rows, ratios: ratios)
            }
            
            rectangleCache.removeAll()
            sizeDidChange()
            TermHandler.shared.unlock()
        }
    }
    
    override func colsDidChange() {
        DispatchQueue.global().async { [self] in
            TermHandler.shared.lock()
            if stackType == .horizontal {
                offsets = TermMultiWindow.offsetsFromRatios(length: cols, ratios: ratios)
            }
            rectangleCache.removeAll()
            sizeDidChange()
            TermHandler.shared.unlock()
        }
    }
    
    /// rectangle cache to avoid computing it every time
    /// invalidated on screen size change
    var rectangleCache : [UUID:(x: Int, y: Int, width: Int, height: Int)] = [:]
    
    /// Gets the coordinates for the subwindow
    /// - Parameter id: the id of the window to get coords for
    /// - Returns: the offsets, width, and height
    func rectangle(for id: UUID) -> (x: Int, y: Int, width: Int, height: Int) {
        if let cached = rectangleCache[id] { return cached }
        guard let idx = subwindows.firstIndex(where: { $0.wid == id }) else { return (0,0,0,0) }
        var offsetX: Int
        var offsetY: Int
        var height : Int
        var width: Int
        
        if stackType == .horizontal {
            height = rows
            offsetY = 0
            if idx == offsets.count-1 { // last
                offsetX = offsets.last!
                width = cols - offsetX
            } else {
                offsetX = offsets[idx]
                width = offsets[idx+1] - offsetX
            }
        } else { // vertical
            width = cols
            offsetX = 0
            if idx == offsets.count-1 { // last
                offsetY = offsets.last!
                height = rows - offsetY
            } else {
                offsetY = offsets[idx]
                height = offsets[idx+1] - offsetY
            }
        }

        // compound if necessary
        if let superwindow = embeddedIn as? TermMultiWindow {
            let (myofx, myofy,_,_) = superwindow.rectangle(for: self.wid)
            offsetX += myofx
            offsetY += myofy
        }
        
        let result = (offsetX,offsetY,width,height)
        rectangleCache[id] = result
        return result
    }
    
    /// Draws a box around the screen
    /// - Parameters:
    ///    - id: the id of the subwindow to box
    ///    - style: the box style (default `.simple`)
    public func boxWindow(id: UUID, _ style: BoxType = .simple) {
        let (ofX,ofY,width,height) = rectangle(for: id)
        switch style {
        case .none:
            return
        default:
            break
        } // the issue with enums that have associated values is you can't test them with == anymore
        
        TermHandler.shared.lock()
        TermHandler.shared.set(TermColor.default, style: TermStyle.default)
        
        TermHandler.shared.moveCursor(toX: 1+ofX, y: 1+ofY)
        // top line
        for _ in 1...width { stdout(DisplaySymbol.horz_top.withStyle(.line)) }
        for y in 2...(height-1) {
            TermHandler.shared.moveCursor(toX: 1+ofX, y: y+ofY)
            stdout(DisplaySymbol.vert_left.withStyle(.line))
            TermHandler.shared.moveCursor(toX: width+ofX, y: y+ofY)
            stdout(DisplaySymbol.vert_left.withStyle(.line))
        }
        TermHandler.shared.moveCursor(toX: 1+ofX, y: height+ofY)
        for _ in 1...width { stdout(DisplaySymbol.horz_top.withStyle(.line)) }
        TermHandler.shared.set(.default, style: .default)
        TermHandler.shared.unlock()
        
        switch style {
        case .ticked(let colTicks, let rowTicks):
            for (col,str) in colTicks {
                if col + str.count >= width { break } // sorry, won't go there
                TermHandler.shared.moveCursor(toX: col+ofX, y: height+ofY)
                stdout(DisplaySymbol.tick_up.withStyle(.line)+str.apply(.default, style: .default))
            }
            for (row,str) in rowTicks {
                if row >= width { break } // ditto
                TermHandler.shared.moveCursor(toX: 1+ofX, y: row+ofY)
                stdout(DisplaySymbol.tick_left.withStyle(.line)+str.apply(.default, style: .default))
            }
            break
        default:
            break
        } // ditto
    }

    public override func requestBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[Character]]) -> Void) {
        guard let idx = subwindows.firstIndex(where: { $0.wid == sub.wid }) else { return }
        var ofX : Int
        var ofY : Int
        var height : Int
        var width: Int
        
        (ofX,ofY,width,height) = rectangle(for: sub.wid)
                
        switch box {
        case .none:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: width), count: height)
            handler(&buffer)

            if stackType == .horizontal {
                draw(buffer, offset: (offsets[idx]+ofX,0+ofY))
            } else {
                draw(buffer, offset: (0+ofX,offsets[idx]+ofY))
            }
        default:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: width-2), count: height-2)
            handler(&buffer)
            
            // boxScreen(box)
            boxWindow(id: sub.wid, box)
            
            if stackType == .horizontal {
                draw(buffer, offset: (1+offsets[idx]+ofX,1+ofY))
            } else {
                draw(buffer, offset: (1+ofX,1+offsets[idx]+ofY))
            }
        }
    }
    
    public override func requestStyledBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[TermCharacter]]) -> Void) {
        guard let idx = subwindows.firstIndex(where: { $0.wid == sub.wid }) else { return }
        var ofX : Int
        var ofY : Int
        var height : Int
        var width: Int
        
        (ofX,ofY,width,height) = rectangle(for: sub.wid)

        switch box {
        case .none:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: width), count: height)
            handler(&buffer)

            if stackType == .horizontal {
                draw(buffer, offset: (ofX,0+ofY), clearSkip: false)
            } else {
                draw(buffer, offset: (0+ofX,ofY), clearSkip: false)
            }
        default:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: width-2), count: height-2)
            handler(&buffer)
            
            // boxScreen(box)
            boxWindow(id: sub.wid, box)

            if stackType == .horizontal {
                draw(buffer, offset: (1+ofX,1+ofY), clearSkip: false)
            } else {
                draw(buffer, offset: (1+ofX,1+ofY),clearSkip: false)
            }
        }
    }

}
