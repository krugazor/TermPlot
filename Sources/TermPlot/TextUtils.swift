import Foundation
import LoremSwiftum
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

let colorMappings = TermColor.allCases.map({ ($0, $0.asRGB) })

#if os(macOS)
func approximateColor(_ col: NSColor?) -> TermColor {
    guard let col = col else { return .default }
    if let rgb = col.usingColorSpace(NSColorSpace.deviceRGB) {
        if rgb.alphaComponent <= 0.5 {
            return .default // because of html
        }
        let r : Float = Float(rgb.redComponent)
        let g : Float  = Float(rgb.greenComponent)
        let b : Float  = Float(rgb.blueComponent)
        
        let distances = colorMappings.compactMap({ arg0 -> (TermColor, Float)? in
            let (tcol,trgb) : (TermColor,(Float,Float,Float)?) = arg0
            if let (tr,tg,tb) = trgb {
                let dsq : Float = (r-tr)*(r-tr)+(b-tb)*(b-tb)+(g-tg)*(g-tg)
                return (tcol, dsq)
            } else {
                return nil
            }
        }).sorted { (arg0, arg1) -> Bool in
            let (_,dsq0) = arg0
            let (_,dsq1) = arg1
            return dsq0 < dsq1
        }
        return distances.first?.0 ?? .default
    }
    
    return .default
}

extension NSFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.bold)
    }
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.italic)
    }
}
#elseif os(iOS)
func approximateColor(_ col: UIColor?) -> TermColor {
    guard let col = col else { return .default }
    var rr : CGFloat = -1
    var gg : CGFloat = -1
    var bb : CGFloat = -1
    var aa : CGFloat = -1
    
    col.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
    if aa <= 0.5 {
        return .default // because of html
    }
    
    // ugly but I don't see an alternative
    if rr < 0 || gg < 0 || bb < 0 { return .default }
    let r = Float(rr)
    let g = Float(gg)
    let b = Float(bb)
    
    let distances = colorMappings.compactMap({ arg0 -> (TermColor, Float)? in
        let (tcol,trgb) : (TermColor,(Float,Float,Float)?) = arg0
        if let (tr,tg,tb) = trgb {
            let dsq : Float = (r-tr)*(r-tr)+(b-tb)*(b-tb)+(g-tg)*(g-tg)
            return (tcol, dsq)
        } else {
            return nil
        }
    }).sorted { (arg0, arg1) -> Bool in
        let (_,dsq0) = arg0
        let (_,dsq1) = arg1
        return dsq0 < dsq1
    }
    return distances.first?.0 ?? .default
}

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

#endif


public func mapAttributes(_ text: NSAttributedString) -> [(TermColor,TermStyle,String)] {
    var result = [(TermColor,TermStyle,String)]()
    
    var cursor = 0
    while cursor < text.length {
        var effectiveRange = NSRange(location: 0,length: 0)
        let attributes = text.attributes(at: cursor, longestEffectiveRange: &effectiveRange, in: NSRange(location: cursor, length: text.length-cursor))
        
        let tcol : TermColor
        if let scolor = attributes[NSAttributedString.Key("NSColor")] { // I hate this with PASSION
            #if os(macOS)
            tcol = approximateColor(scolor as? NSColor)
            #elseif os(iOS)
            tcol = approximateColor(scolor as? UIColor)
            #elseif os(Linux)
            tcol = scolor as? TermColor ?? .default
            #endif
        } else {
            tcol = .default
        }
        
        let tstyle : TermStyle
        if let sfont = attributes[NSAttributedString.Key("NSFont")] { // I hate this with PASSION
            #if os(macOS)
            if (sfont as? NSFont)?.isBold ?? false {
                tstyle = .bold
            } else if (sfont as? NSFont)?.isItalic ?? false {
                tstyle = .italic
            } else {
                tstyle = .default
            }
            #elseif os(iOS)
            if (sfont as? UIFont)?.isBold ?? false {
                tstyle = .bold
            } else if (sfont as? UIFont)?.isItalic ?? false {
                tstyle = .italic
            } else {
                tstyle = .default
            }
            #elseif os(Linux)
            tstyle = sfont as? TermStyle ?? .default
            #endif
        } else {
            tstyle = .default
        }
        let end = effectiveRange.upperBound
        cursor = end
        let str = text.attributedSubstring(from: effectiveRange).string.replacingOccurrences(of: "\t", with: " ")
        result.append((tcol,tstyle,str))
    }
    
    return result
}

public func underestimatedLines(_ txt : [(TermColor,TermStyle,String)]) -> Int {
    return txt.reduce(0) { $0 + $1.2.components(separatedBy: CharacterSet.newlines).count }
}

/// From https://stackoverflow.com/questions/33305157/split-string-into-groups-with-specific-length
extension String {
    /// Splits a string into groups of `every` n characters, grouping from left-to-right by default. If `backwards` is true, right-to-left.
    public func split(every: Int, backwards: Bool = false) -> [String] {
        var result = [String]()

        for i in stride(from: 0, to: self.count, by: every) {
            switch backwards {
            case true:
                let endIndex = self.index(self.endIndex, offsetBy: -i)
                let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
                result.insert(String(self[startIndex..<endIndex]), at: 0)
            case false:
                let startIndex = self.index(self.startIndex, offsetBy: i)
                let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
                result.append(String(self[startIndex..<endIndex]))
            }
        }

        return result
    }
}

public func toLines(_ txt : [(TermColor,TermStyle,String)], in width: Int) -> [([(TermColor,TermStyle)], String)] {
    var resultBefSplit : [([(TermColor,TermStyle)], String)] = []
    
    // actual lines
    var currentLine = ""
    var currentStyles : [(TermColor,TermStyle)] = []
    
    for item in txt {
        let splitted = item.2.components(separatedBy: CharacterSet.newlines)
        if splitted.count == 1 { // standard case
            for _ in item.2 { currentStyles.append((item.0, item.1)) }
            currentLine += item.2
        } else {
            var sub = splitted[0]
            for _ in sub { currentStyles.append((item.0, item.1)) }
            currentLine += sub
            
            resultBefSplit.append((currentStyles, currentLine))
            currentLine = ""
            currentStyles = []
            
            for i in 1..<(splitted.count-1) {
                sub = splitted[i]
                for _ in sub { currentStyles.append((item.0, item.1)) }
                currentLine += sub
                
                resultBefSplit.append((currentStyles, currentLine))
                currentLine = ""
                currentStyles = []
            }
            
            // last line
            sub = splitted[splitted.count-1]
            for _ in sub { currentStyles.append((item.0, item.1)) }
            currentLine += sub
        }
    }
    
    if currentStyles.count > 0 {
        resultBefSplit.append((currentStyles, currentLine))
        currentLine = ""
        currentStyles = []
    }
    
    var result : [([(TermColor,TermStyle)], String)] = []

    for line in resultBefSplit {
        if line.0.count <= width { result.append(line) }
        else {
            var counter = 0
            let splitted = line.1.split(every: width)
            for split in splitted {
                let styles = Array(line.0[counter...counter+split.count-1])
                result.append((styles, split))
                counter += split.count
            }
        }
    }
    
    return result
}

public func fit(_ txt : [(TermColor,TermStyle,String)], in width: Int, lines countLines: Int = 1000) -> [[TermCharacter]] {
    var result = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: width), count: countLines)
    
    let splitted = toLines(txt, in: width)
    
    // fit in buffer
    var cursor = 0 // start from last line
    while cursor < countLines && cursor < splitted.count {
        var tcLine = [TermCharacter]() //  = splitted[splitted.count - 1 - cursor].map({ TermCharacter($0, color: .default, styles: [.default]) })
        let split = splitted[splitted.count - 1 - cursor]
        for i in 0..<split.0.count {
            tcLine.append(TermCharacter(split.1[split.1.index(split.1.startIndex, offsetBy: i)],
                                        color: split.0[i].0,
                                        styles: [split.0[i].1]))
        }
        tcLine = tcLine + [TermCharacter](repeating: TermCharacter(), count: width - tcLine.count)
        result[result.count-1-cursor] = tcLine
        cursor += 1
    }
    
    return result
}

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

public func generateAttributedString(minLength: Int) -> NSAttributedString {
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
        let font = style == 2 ? UIFont.italicSystemFont(ofSize: UIFont.systemFontSize) :
            (style == 1 ? UIFont.boldSystemFont(ofSize: UIFont.systemFontSize) : UIFont.systemFont(ofSize: UIFont.systemFontSize))
        result.addAttributes([
            NSAttributedString.Key("NSColor"): UIColor.random,
            NSAttributedString.Key("NSFont"): font
        ], range: NSRange(location: length-remaining, length: span))
        #elseif os(Linux)
        let font = style == 2 ? TermStyle.italic : (style == 1 ? TermStyle.bold : TermStyle.default)
        let color = TermColor.allCases.randomElement() ?? .default
        result.addAttributes([
            NSAttributedString.Key("NSColor"): color,
            NSAttributedString.Key("NSFont"): font
        ], range: NSRange(location: length-remaining, length: span))
        #endif
        remaining -= span
    }
    
    return result
}


public func debugTermPrint(_ buf: [[TermCharacter]]) {
    print("------------------")
    for line in buf {
        let out = line.map({ String($0.char) }).joined()
        print("| " + out + " |")
    }
    print("------------------")
}


#if os(Linux)
extension NSAttributedString {
    public convenience init(_ string: String, color: TermColor, style: TermStyle) {
        self.init(string: string, attributes: [
            NSAttributedString.Key("NSColor"): color,
            NSAttributedString.Key("NSFont"): style
        ])
    }
}

extension NSMutableAttributedString {
    public func addAttributes(color: TermColor?, style: TermStyle?, range: NSRange) {
        var attrs : [NSAttributedString.Key : Any] = [:]
        if let color = color {
            attrs[NSAttributedString.Key("NSColor")] = color
        }
        if let style = style {
            attrs[NSAttributedString.Key("NSFont")] = style
        }
        
        self.addAttributes(attrs, range: range)
    }
}
#endif
