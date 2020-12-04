import Foundation
import TermPlot
import ArgumentParser
// import SwiftLoggerClient

// doDemo()
// doSeriesDemo()

// SwiftLogger.setupForHTTP(URL(string: "http://localhost:8080")!, appName: "TermPlot")

//let live = LiveSeriesWindow(tick: 1, total: 80, input: FileHandle.standardInput)
//live.seriesStyle = .line
//live.maxValue = 5
//live.seriesColor = .quarters(.green, .blue, .yellow, .red)
//live.start()
//
//RunLoop.current.run(until: Date.distantFuture)

extension TermColor : ExpressibleByArgument {
}

extension StandardSeriesWindow.StandardSeriesStyle : ExpressibleByArgument {
}

struct TermPlot : ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract:
            """
        Utility to plot graphs in a terminal window. Uses ANSI colors and UTF-8 display characters.
        If no color scheme or style is configured, will use line/light_red as a default
        List of available colors:
        \(TermColor.allCases
            .map({ "\($0)" })
            .joined(separator: ", "))
        """,
        version: "1.0.0")
 
    @Flag(name: .long, help: "Runs the animation presentation")
    var presentation = false
    
    @Flag(name: .long, help: "Runs the demo")
    var demo = false

    @Option(name: .shortAndLong, help: "The file to read from. If absent, will read from standard input")
    var file: String?
    
    @Option(name: .shortAndLong, help: "Monochrome color to use (default: light_red). Mutually exclusive with other color options")
    var mColor: TermColor?
    
    @Option(name: .shortAndLong, help: "Quarter colors to use (default: green,blue,yellow,red). Mutually exclusive with other color options", transform: { (arg) -> [TermColor] in
        return arg.components(separatedBy: ",").compactMap({ col in
            // let's abuse CaseIterable
            if let colcase = TermColor.allCases.first(where: { $0.defaultValueDescription == col})?.rawValue {
                return TermColor(rawValue: colcase)
            } else {
                return nil
            }
        })
    })
    var qColors: [TermColor]?
    
    @Option(name: .shortAndLong, help: "Percent quartile colors to use (default: green,blue,yellow,red). Mutually exclusive with other color options", transform: { (arg) -> [TermColor] in
        return arg.components(separatedBy: ",").compactMap({ col in
            // let's abuse CaseIterable
            if let colcase = TermColor.allCases.first(where: { $0.defaultValueDescription == col})?.rawValue {
                return TermColor(rawValue: colcase)
            } else {
                return nil
            }
        })
    })
    var pColors: [TermColor]?
    
    @Option(name: .shortAndLong, help: "Style of the graph (supported values: \(StandardSeriesWindow.StandardSeriesStyle.allCases)")
    var style : StandardSeriesWindow.StandardSeriesStyle?
    
    @Flag(name: .long, help: "Should continue monitoring input for changes. By default, the program does not update anymore at the EOF")
    var live = false
    
    mutating func run() throws {
        if presentation {
            doDemo()
            return
        } else if demo {
            doSeriesDemo()
            return
        }
        
        let colorArgs : [Any?] = [mColor,qColors,pColors]
        if colorArgs.compactMap({ $0 }).count > 1 {
            print("Only one color scheme is allowed, please choose bewteen monochromatic, quarters, or percentage quartiles")
            Foundation.exit(-1)
        }
        
        let winStyle : StandardSeriesWindow.StandardSeriesStyle
        if let sty = style {
            winStyle = sty
        } else {
            winStyle = .line
        }
        
        let winColor : StandardSeriesWindow.StandardSeriesColorScheme
        if let col = mColor {
            winColor = .monochrome(col)
        } else if var col = qColors {
            if col.count == 4 {
                winColor = .quarters(col[0], col[1], col[2], col[3])
            } else { // complete the rest with random colors
                while col.count < 4 {
                    if let rcol = TermColor.allCases.randomElement(), !col.contains(rcol) {
                        col.append(rcol)
                    }
                }
                winColor = .quarters(col[0], col[1], col[2], col[3])
            }
        } else if var col = pColors {
            if col.count == 4 {
                winColor = .quartiles(col[0], col[1], col[2], col[3])
            } else { // complete the rest with random colors
                while col.count < 4 {
                    if let rcol = TermColor.allCases.randomElement(), !col.contains(rcol) {
                        col.append(rcol)
                    }
                }
                winColor = .quartiles(col[0], col[1], col[2], col[3])
            }
        } else {
            winColor = .monochrome(.light_red)
        }
        
        if live {
            if let file = file, let handle = FileHandle.init(forReadingAtPath: file) {
                let (cols,_) = TermSize2()
                let window = LiveSeriesWindow(tick: 1, total: Double(cols), input: handle)
                window.seriesColor = winColor
                window.seriesStyle = winStyle
                window.start()
            } else {
                // can stdin be anything but live?
                let (cols,_) = TermSize2()
                let window = LiveSeriesWindow(tick: 1, total: Double(cols), input: FileHandle.standardInput)
                window.seriesColor = winColor
                window.seriesStyle = winStyle
                window.start()
            }
            RunLoop.current.run(until: Date.distantFuture)
        } else if let file = file {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file)), let str = String(data: data, encoding: .utf8) {
                let numbers = str.components(separatedBy: CharacterSet.newlines).compactMap( { str -> Double? in
                    let trimmed = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !trimmed.isEmpty { return Double(trimmed) }
                    else { return nil }
                })
                let (cols,_) = TermSize2()
                let window = StandardSeriesWindow(tick: 1, total: Double(cols))
                window.seriesColor = winColor
                window.seriesStyle = winStyle
                // TODO: update on change
                window.replaceValues(with: numbers)
                window.start()
                RunLoop.current.run(until: Date.distantFuture)
            } else {
                print("No numbers found in \(file)\nIs it a list of numbers (one per line)?")
            }
        } else {
            // can stdin be anything but live?
            let data = FileHandle.standardInput.availableData
            if let str = String(data: data, encoding: .utf8) {
                let numbers = str.components(separatedBy: CharacterSet.newlines).compactMap( { str -> Double? in
                    let trimmed = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !trimmed.isEmpty { return Double(trimmed) }
                    else { return nil }
                })
                let window = StandardSeriesWindow(tick: 1, total: Double(numbers.count))
                window.seriesColor = winColor
                window.seriesStyle = winStyle
                window.replaceValues(with: numbers)
                window.start()
                RunLoop.current.run(until: Date.distantFuture)
            } else {
                print("No numbers found in stdin\nIs it a list of numbers (one per line)?")
            }
        }
    }
}

TermPlot.main()
