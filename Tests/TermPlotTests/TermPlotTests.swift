import XCTest
import LoremSwiftum
@testable import TermPlot

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

#if os(macOS)
extension NSColor {
    static var random: NSColor {
        return NSColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
#elseif os(iOS)
extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
#endif


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
    
    func generateAttributedString(minLength: Int) -> NSAttributedString {
        var str = Lorem.sentence
        var length = str.count
        
        while length < minLength {
            if Bool.random() { str += "\n" }
            else { str += " " }
            str += Lorem.paragraph
            length = str.count
        }
        
        var remaining = length
        let result = NSMutableAttributedString(string: str)
        while remaining > 0 {
            let span = Int.random(in: 1...(min(remaining, 15)))
            let style = Int.random(in: 0...2) // 0 - default, 1 - bold, 2 - italic
            
            #if os(macOS)
            let fontDesc = NSFontDescriptor(fontAttributes: [NSFontDescriptor.AttributeName.traits : [style == 2 ? NSFontDescriptor.SymbolicTraits.italic : NSFontDescriptor.SymbolicTraits.bold]])
            let font : NSFont = style > 0 ? NSFont(descriptor: fontDesc, size: NSFont.systemFontSize)! : NSFont.systemFont(ofSize: NSFont.systemFontSize)
            result.addAttributes([
                NSAttributedString.Key("NSColor"): NSColor.random,
                NSAttributedString.Key("NSFont"): font
            ], range: NSRange(location: length-remaining, length: span))
            #elseif os(iOS)
            
            #endif
            remaining -= span
        }
        
        return result
    }
    
    func testWebText() {
        if let data = try? Data(contentsOf: URL(string: "https://blog.krugazor.eu/2018/08/31/we-suck-as-an-industry/")!),
           let html = NSAttributedString(html: data,
                                         baseURL: URL(string: "https://blog.krugazor.eu/2018/08/31/we-suck-as-an-industry/")!,
                                         documentAttributes: nil) {
            let lines = underestimatedLines(mapAttributes(html))
            XCTAssert(lines > 0)
            
            let buffer = fit(mapAttributes(html), in: 80, lines: 47)
            XCTAssert(buffer.count > 0)
            debugTermPrint(buffer)
        } else {
            XCTFail()
        }
    }
    
    func testText() {
        let str = generateAttributedString(minLength: 8000)
        let lines = underestimatedLines(mapAttributes(str))
        XCTAssert(lines > 0)
        
        let splitted = toLines(mapAttributes(str), in: 80)
        XCTAssert(splitted.count > 0)
        
        let buffer = fit(mapAttributes(str), in: 80, lines: 47)
        XCTAssert(buffer.count > 0)
        debugTermPrint(buffer)
        
    }
    
    static var allTests = [
        ("testColors", testColors),
        ("testCharacters", testCharacters),
        ("testUtils", testUtils),
        ("testMulti", testMulti),
    ]
}
