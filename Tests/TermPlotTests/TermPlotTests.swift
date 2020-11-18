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
        let (c,r) = TermSize()
        print("\(c) cols x \(r) rows")
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

    static var allTests = [
        ("testColors", testColors),
        ("testCharacters", testCharacters),
        ("testUtils", testUtils),
    ]
}
