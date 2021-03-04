import Foundation
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
