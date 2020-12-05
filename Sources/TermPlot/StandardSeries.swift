import Foundation

/// Standard series display: x number of y values
public class StandardSeriesWindow : TermWindow {
    /// Publicly exposed possible styles (self explanatory)
    public enum StandardSeriesStyle : String, CaseIterable {
        case block
        case line
        case dot
    }
    /// Color schemes
    /// - monochrome
    /// - quarters (1/4 of the screen is the same color)
    /// - quartiles (1/4 of the *values* is the same color)
    public enum StandardSeriesColorScheme {
        case monochrome(TermColor)
        case quarters(TermColor,TermColor,TermColor,TermColor)
        case quartiles(TermColor,TermColor,TermColor,TermColor)
    }
    
    /// x-axis range size
    var totalTime : TimeInterval
    /// x-axis tick mark
    var timeTick : TimeInterval
    /// x-axis tick count
    var timeCount : Int { Int(ceil(totalTime/timeTick)) }
    
    /// ceiling of the graph, if necessary
    /// will be computed if nil
    public var maxValue : Double?
    /// Current series color scheme
    public var seriesColor : StandardSeriesColorScheme = .monochrome(.red) {
        didSet {
            computeRowStyles()
        }
    }
    /// Current series style
    public var seriesStyle : StandardSeriesStyle = .block {
        didSet {
            computeRowStyles()
        }
    }
    
    /// The actual y values
    var values : [Double]
    
    /// Pre-computed color/style by row (needed for quartiles most of all)
    var rowStyles : [(color: TermColor, styles:[TermStyle])]
    
    /// Recompute row styles (needed for quartiles most of all) when the number of rows changes
    override func rowsDidChange() {
        super.rowsDidChange()
        computeRowStyles()
    }
    
    /// Recompute row styles
    func computeRowStyles() {
        rowStyles = [(color: TermColor, styles:[TermStyle])](repeating: (.default, [.default]), count: rows-2)
        
        // precompute quartiles if necessary
        let low : Double
        let mid : Double
        let high : Double
        switch seriesColor {
        case .quartiles(_, _, _, _):
            var maxHeight = ceil(maxValue ?? self.values.max() ?? 1)
            if maxHeight == 0 { maxHeight = 1 }
            let sorted = values.sorted().map({ ($0 * Double(rows-2)) / maxHeight})
            low = sorted[sorted.count/4]
            mid = sorted[sorted.count/2]
            high = sorted[(3*sorted.count)/4]
        default:
            low = 0
            mid = 0
            high = 0
        }
        for i in 0..<rowStyles.count {
            switch seriesColor {
            case .monochrome(let c):
                rowStyles[i].color = c
                if seriesStyle == .block {
                    rowStyles[i].styles = [.swap, .hide]
                } else {
                    rowStyles[i].styles = [.bold]
                }
            case .quarters(let q1, let q2, let q3, let q4):
                if i < (rows-2)/4 {
                    rowStyles[i].color = q1
                } else if i < (rows-2)/2 {
                    rowStyles[i].color = q2
                } else if i < 3*(rows-2)/4 {
                    rowStyles[i].color = q3
                } else {
                    rowStyles[i].color = q4
                }
                if seriesStyle == .block {
                    rowStyles[i].styles = [.swap, .hide]
                } else {
                    rowStyles[i].styles = [.bold]
                }
            case .quartiles(let q1, let q2, let q3, let q4):
                if Double(i) < low {
                    rowStyles[i].color = q1
                } else if Double(i) < mid {
                    rowStyles[i].color = q2
                } else if Double(i) < high {
                    rowStyles[i].color = q3
                } else {
                    rowStyles[i].color = q4
                }
                if seriesStyle == .block {
                    rowStyles[i].styles = [.swap, .hide]
                } else {
                    rowStyles[i].styles = [.bold]
                }
                break
            }
        }
    }
    
    /// Public initializer
    /// - Parameters:
    ///   - tick: width of an x-interval
    ///   - total: range of the x-axis
    public init(tick: TimeInterval, total: TimeInterval) {
        totalTime = total
        timeTick = tick
        values = [Double](repeating: 0, count: Int(ceil(totalTime/timeTick)))
        rowStyles = []
        defer {
            computeRowStyles()
        }
        
        super.init()
    }
    
    /// Adds a value to the end of the buffer
    /// - Parameter val: the value
    public func addValue(_ val: Double) {
        values.append(val)
        self.display()
    }
    /// Adds values to the end of the buffer
    /// - Parameter vals: the values
    public func addValues(_ vals: [Double]) {
        values.append(contentsOf: vals)
        self.display()
    }
    /// Replaces all the values in the buffer
    /// - Parameter with: the new values
    public func replaceValues(with: [Double]) {
        values = with
        self.display()
    }
    /// Reserve-and-modify mechanism to replace the values in the buffer selectively
    /// - Parameter apply: the block to call for new values
    public func modifyValues(_ apply: @escaping ([Double])->[Double]) {
        let replacement = apply(values)
        self.replaceValues(with: replacement)
    }
    
    /// Overrided function to start displaying the graph
    public func start() {
        self.display()
    }
    
    /// Overrided function to stop displaying the graph
    public func stop() {
    }
    
    /// Display the buffer, based on current style and colors
    func display() {
        clearScreen()
        // calculate max value
        let maxHeight = ceil(maxValue ?? self.values.max() ?? 1)
        var conversionFactor = Double(rows-2) / maxHeight
        if conversionFactor.isNaN || conversionFactor.isInfinite { conversionFactor = 1 }
        // draw axises
        // TODO
        // map timecount items in cols bins
        var heldValues = [(x: Double, y: Double)]()
        for x in 0..<timeCount {
            heldValues.append((Double(x+1)*timeTick, values[x]))
        }
        var timeCols = [Double]()
        let start = heldValues[0].x
        timeCols.append(start)
        let timeColStep = totalTime/Double(cols-1)
        for c in 1..<cols-2 {
            timeCols.append(start+Double(c)*timeColStep)
        }
        timeCols.append(heldValues[heldValues.count-1].x)
        let mapping = TimeSeriesWindow.mapDomains(heldValues, to: timeCols).map({ ($0.x,$0.y.isNaN ? 0 : $0.y*conversionFactor) })
        
        // if we are using quartiles, recompute
        switch seriesColor {
        case .quartiles(_, _, _, _):
            computeRowStyles()
        default:
            break
        }
        
        if seriesStyle == .block {
            // draw the columns
            requestStyledBuffer { buffer in
                for rowIdx in 0..<buffer.count {
                    for colIdx in 0..<buffer[0].count {
                        let val = Int(mapping[colIdx].1)
                        if val >= rowIdx {
                            buffer[buffer.count-rowIdx-1][colIdx] = TermCharacter(".", color: rowStyles[rowIdx].color, styles: rowStyles[rowIdx].styles)
                        }
                    }
                }
            }
        } else if seriesStyle == .dot {
            // compute dot position
            let dotHeight = mapping.map { (col,val) -> Int in
                return Int(round(val))
            }
            requestStyledBuffer { buffer in
                for colIdx in 0..<buffer[0].count {
                    let dotPosition = dotHeight[colIdx]
                    if dotPosition < buffer.count {
                        buffer[buffer.count-dotPosition-1][colIdx] = TermCharacter(DisplaySymbol.point.cWithStyle(.dots), color: rowStyles[dotPosition].color, styles: rowStyles[dotPosition].styles)
                    }
                }
            }
        } else if seriesStyle == .line {
            // that's the complicated one, the line has to appear kind of continuous
            // compute dot position
            let dotHeight = mapping.map { (col,val) -> Int in
                return Int(round(val))
            }
            requestStyledBuffer { buffer in
                for colIdx in 0..<buffer[0].count {
                    let dotPosition = min(max(dotHeight[colIdx],0), buffer.count-1)
                    if colIdx == 0 || colIdx+1 == buffer[0].count {
                        // begin and end with a flat
                        buffer[buffer.count-dotPosition-1][colIdx] = TermCharacter(DisplaySymbol.horz_top.cWithStyle(.line),
                                                                                   color: rowStyles[dotPosition].color,
                                                                                   styles: rowStyles[dotPosition].styles)
                    } else {
                        let nextPos = min(max(dotHeight[colIdx+1],0), buffer.count-1)
                        if nextPos == dotPosition {
                            buffer[buffer.count-dotPosition-1][colIdx] = TermCharacter(DisplaySymbol.horz_top.cWithStyle(.line),
                                                                                       color: rowStyles[dotPosition].color,
                                                                                       styles: rowStyles[dotPosition].styles)
                        } else if nextPos > dotPosition {
                            // make a connection
                            buffer[buffer.count-dotPosition-1][colIdx] = TermCharacter(DisplaySymbol.bot_right.cWithStyle(.line),
                                                                                       color: rowStyles[dotPosition].color,
                                                                                       styles: rowStyles[dotPosition].styles)
                            for i in (dotPosition+1)..<nextPos {
                                buffer[buffer.count-i-1][colIdx] = TermCharacter(DisplaySymbol.vert_right.cWithStyle(.line),
                                                                                 color: rowStyles[i].color,
                                                                                 styles: rowStyles[i].styles)
                            }
                            buffer[buffer.count-nextPos-1][colIdx] = TermCharacter(DisplaySymbol.top_left.cWithStyle(.line),
                                                                                   color: rowStyles[nextPos].color,
                                                                                   styles: rowStyles[nextPos].styles)
                       } else if nextPos < dotPosition {
                        // make a connection
                        buffer[buffer.count-dotPosition-1][colIdx] = TermCharacter(DisplaySymbol.top_right.cWithStyle(.line),
                                                                                   color: rowStyles[dotPosition].color,
                                                                                   styles: rowStyles[dotPosition].styles)
                        for i in (nextPos+1)..<dotPosition {
                            buffer[buffer.count-i-1][colIdx] = TermCharacter(DisplaySymbol.vert_right.cWithStyle(.line),
                                                                             color: rowStyles[i].color,
                                                                             styles: rowStyles[i].styles)
                        }
                        buffer[buffer.count-nextPos-1][colIdx] = TermCharacter(DisplaySymbol.bot_left.cWithStyle(.line),
                                                                               color: rowStyles[nextPos].color,
                                                                               styles: rowStyles[nextPos].styles)
                       }
                    }
                }
            }
        }
    }
    
    /// Used for interpolation, gets the function that defines the line between two points
    /// - Parameters:
    ///   - point1: first point
    ///   - point2: second point
    /// - Returns: `a*x+b*y+c=0` equation parameters (a,b, and c)
    static func getLineParameters(point1: (x: Double, y:Double), point2: (x: Double, y:Double)) -> (a: Double, b: Double, c: Double) {
        let a = point1.y - point2.y
        let b = point2.x - point1.x
        let c = ((-b)*point1.y) + ((-a)*point1.x) // eeeeeeeet oui
        return (a,b,c)
    }
    
    /// Interpolation function
    /// - Parameters:
    ///   - points: the discreet points to start from
    ///   - to: the discreet domain (x) to map onto
    /// - Returns: the discreet mapped points
    static func mapDomains(_ points: [(x: Double, y:Double)], to: [Double]) -> [(x: Double, y:Double)] {
        // just in case
        let to = to.sorted()
        let minX = to.min() ?? 0
        let maxX = to.max() ?? 1
        let points = points.filter {
            $0.x >= minX && $0.x <= maxX
        }
        
        var result = [(x: Double, y:Double)]()
        for x in to {
            // bracket then compute
            let before = points.firstIndex(where: { $0.x > x })
            let after = points.lastIndex(where: { $0.x < x })
            if let before = before, let after = after {
                let bIdx = max(0,before - 1)
                let aIdx = min(points.count-1, after + 1)
                if bIdx == aIdx { result.append(points[bIdx]) }
                else {
                    let (a,b,c) = getLineParameters(point1: points[bIdx], point2: points[aIdx])
                    let y = (-a/b)*x - (c/b)
                    result.append((x,y))
                }
            } else if let after = after {
                // straight
                result.append((x,points[min(points.count-1, after + 1)].y))
            } else if let before = before {
                // straight
                result.append((x,points[max(0,before - 1)].y))
            } else {
                result.append((x,0))
            }
        }
        
        return result
    }
}
