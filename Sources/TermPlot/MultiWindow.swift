import Foundation

public class TermMultiWindow : TermWindow {
    public enum StackType {
        case horizontal
        case vertical
    }
    
    public struct ConfigurationError : Error {
        
    }
    
    let subwindows : [TermWindow]
    let stackType: StackType
    let ratios : [Float]
    var offsets : [Int]
    
    static func offsetsFromRatios(length: Int, ratios: [Float]) -> [Int] {
        if ratios.isEmpty { return [] }
        
        let totalRatio = ratios.reduce(0.0) { $0+$1 } // not necessarily normalized
        let totalLength = Float(length)
        var currentlyUsed = 0
        
        var lengthes = [Int]()
        lengthes.append(0)
        currentlyUsed = Int((ratios[0] * totalLength)/totalRatio)
        for i in 1..<(ratios.count - 1) {
            let value = Int((ratios[i] * totalLength)/totalRatio)
            lengthes.append(value)
            currentlyUsed += value
        }
        lengthes.append(length-currentlyUsed)
        
        return lengthes
    }
    
    convenience init(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws {
        try self.init(stack: stack, ratios: lrat, subs)
    }
    
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
    
    public static func setup(stack: StackType, ratios lrat: [Float], _ subs: TermWindow...) throws -> TermMultiWindow {
        return try TermMultiWindow(stack: stack, ratios: lrat, subs)
    }
    
    /// function to start displaying the graph
    public func start() {
        for win in subwindows {
            if let win = win as? StandardSeriesWindow {
                win.start()
            }
        }
    }
    
    /// function to stop displaying the graph
    public func stop() {
        for win in subwindows {
            if let win = win as? StandardSeriesWindow {
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
        if stackType == .vertical {
            offsets = TermMultiWindow.offsetsFromRatios(length: rows, ratios: ratios)
        }
        sizeDidChange()
    }
    
    override func colsDidChange() {
        if stackType == .horizontal {
            offsets = TermMultiWindow.offsetsFromRatios(length: cols, ratios: ratios)
        }
        sizeDidChange()
    }
    
    public override func requestBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[Character]]) -> Void) {
        guard let idx = subwindows.firstIndex(where: { $0.wid == sub.wid }) else { return }
        var height : Int
        var width: Int
        
        if stackType == .horizontal {
            height = rows
            if idx == offsets.count-1 { // last
                width = cols - offsets.last!
            } else {
                width = offsets[idx+1] - offsets[idx]
            }
        } else { // vertical
            width = cols
            if idx == offsets.count-1 { // last
                height = rows - offsets.last!
            } else {
                height = offsets[idx+1] - offsets[idx]
            }
        }
        
        switch box {
        case .none:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: width), count: height)
            handler(&buffer)

            if stackType == .horizontal {
                draw(buffer, offset: (offsets[idx],0))
            } else {
                draw(buffer, offset: (0,offsets[idx]))
            }
        default:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: width-2), count: height-2)
            handler(&buffer)
            
            boxScreen(box)
            
            if stackType == .horizontal {
                draw(buffer, offset: (1+offsets[idx],1))
            } else {
                draw(buffer, offset: (1,1+offsets[idx]))
            }
        }
    }
    
    public override func requestStyledBuffer(for sub: TermWindow, box: TermWindow.BoxType = .simple, _ handler: (inout [[TermCharacter]]) -> Void) {
        guard let idx = subwindows.firstIndex(where: { $0.wid == sub.wid }) else { return }
        var height : Int
        var width: Int
        
        if stackType == .horizontal {
            height = rows
            if idx == offsets.count-1 { // last
                width = cols - offsets.last!
            } else {
                width = offsets[idx+1] - offsets[idx]
            }
        } else { // vertical
            width = cols
            if idx == offsets.count-1 { // last
                height = rows - offsets.last!
            } else {
                height = offsets[idx+1] - offsets[idx]
            }
        }
        
        switch box {
        case .none:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: width), count: height)
            handler(&buffer)

            if stackType == .horizontal {
                draw(buffer, offset: (offsets[idx],0), clearSkip: false)
            } else {
                draw(buffer, offset: (0,offsets[idx]), clearSkip: false)
            }
        default:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: width-2), count: height-2)
            handler(&buffer)
            
            boxScreen(box)
            
            if stackType == .horizontal {
                draw(buffer, offset: (1+offsets[idx],1), clearSkip: false)
            } else {
                draw(buffer, offset: (1,1+offsets[idx]),clearSkip: false)
            }
        }
    }

}
