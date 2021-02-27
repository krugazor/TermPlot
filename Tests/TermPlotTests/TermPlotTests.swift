import XCTest
@testable import TermPlot

final class TermPlotTests: XCTestCase {
    func testColors() {
        for s in TermStyle.allCases {
            for c in TermColor.allCases {
                print("This is a test \(s.rawValue)-\(c.rawValue)".apply(c,style: s))
            }
        }
    }

    func testCharacters() {
        for s in DisplayStyle.allCases {
            for c in DisplaySymbol.allCases {
                print(c.withStyle(s))
            }
        }
    }

    func testUtils() {
        print("This test is highly unreliable...")
        #if os(macOS)
        let (c,r) = TermSize()
        print("\(c) cols x \(r) rows")
        #endif
        let (c2,r2) = TermSize2()
        print("\(c2) cols x \(r2) rows")
        print("10s of listening to size changes...")
        TermHandler.shared.windowResizedAction = {
            print("\($0.cols) cols x \($0.rows) rows")
        }
        for _ in 1...10 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
        }
    }
    
    func testCursors() {
        print("testing left")
        TermHandler.shared.set(TermColor.light_red, styles: [.swap, .hide])
        for _ in 0..<10 {
            TermHandler.shared.put(s: "@")
        }
        TermHandler.shared.moveCursorLeft(5)
        TermHandler.shared.set(TermColor.blue, styles: [.swap, .hide])
        for _ in 0..<5 {
            TermHandler.shared.put(s: "@")
        }
        TermHandler.shared.set(TermColor.default, style: .default)
        TermHandler.shared.put(s: "\n")
        
        print("testing right")
        TermHandler.shared.moveCursorRight(5)
        TermHandler.shared.set(TermColor.blue, styles: [.swap, .hide])
        for _ in 0..<5 {
            TermHandler.shared.put(s: "@")
        }
        TermHandler.shared.set(TermColor.default, style: .default)
        TermHandler.shared.put(s: "\n")

        print("testing up")
        TermHandler.shared.set(TermColor.red, styles: [.swap, .hide])
        for _ in 0..<10 {
            TermHandler.shared.put(s: "@@@@@@@@@@\n")
        }
        TermHandler.shared.moveCursorUp(5)
        TermHandler.shared.set(TermColor.blue, styles: [.swap, .hide])
        for _ in 0..<5 {
            TermHandler.shared.put(s: "@@@@@@@@@@\n")
        }

        TermHandler.shared.set(TermColor.default, style: .default)
        TermHandler.shared.put(s: "\n")
        
        print("testing down")
        TermHandler.shared.set(TermColor.red, styles: [.swap, .hide])
        for _ in 0..<10 {
            TermHandler.shared.put(s: "@@@@@@@@@@\n")
        }
        TermHandler.shared.moveCursorUp(10)
        TermHandler.shared.moveCursorDown(5)
        TermHandler.shared.set(TermColor.blue, styles: [.swap, .hide])
        for _ in 0..<5 {
            TermHandler.shared.put(s: "@@@@@@@@@@\n")
        }

        TermHandler.shared.set(TermColor.default, style: .default)
        TermHandler.shared.put(s: "\n")
    }
    func testMapping() {
        let measures : [(Double,Double)] = [(1.0,5.0), (2.66,8), (4.5,5), (6.33, 6), (8,10)]
        let ticks : [Double] = [1,2,3,4,5,6,7,8]
         let mapping = TimeSeriesWindow.mapDomains(measures, to: ticks)
        print(mapping)
    }
    
    func testMulti() {
        var v1 = 1
        let series1 = TimeSeriesWindow(tick: 0.25, total: 8) {
            v1 += 1
            v1 = v1 % 10
            let random = Int.random(in: 0...v1)
            return Double(random)
        }
        series1.seriesColor = .monochrome(.light_cyan)

        var v2 = 1
        let series2 = TimeSeriesWindow(tick: 0.25, total: 8) {
            v2 += 1
            v2 = v1 % 10
            let random = Int.random(in: 0...v2)
            return Double(random)
        }
        series2.seriesColor = .monochrome(.light_cyan)

        guard let multi = try? TermMultiWindow(stack: .vertical, ratios: [0.5,0.5], series1,series2) else { XCTFail() ; return }
        multi.start()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 60))

    }

    static var allTests = [
        ("testColors", testColors),
        ("testCharacters", testCharacters),
        ("testUtils", testUtils),
        ("testMulti", testMulti),
    ]
}
