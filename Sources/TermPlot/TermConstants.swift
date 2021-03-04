import Foundation

// MARK: Colors
/// The ANSI colors (self explanatory)
public enum TermColor : Int, CaseIterable {
    case black = 0
    case light_black = 60
    case red = 1
    case light_red = 61
    case green = 2
    case light_green = 62
    case yellow = 3
    case light_yellow = 63
    case blue = 4
    case light_blue = 64
    case magenta = 5
    case light_magenta = 65
    case cyan = 6
    case light_cyan = 66
    case white = 7
    case light_white = 67
    case `default` = 9
    
    var asRGB : (r: Float, g: Float, b: Float)? {
        switch self {
        case .black:
            return (0,0,0)
        case .light_black:
            return (0,0,0)
        case .red:
            return (255/255,0,0)
        case .light_red:
            return (194/255,54/255,33/255)
        case .green:
            return (0,255/255,0)
        case .light_green:
            return (37/255,188/255,36/255)
        case .yellow:
            return (255/255,255/255,0)
        case .light_yellow:
            return (173/255,173/255,39/255)
        case .blue:
            return (0,0,255/255)
        case .light_blue:
            return (73/255,46/255,225/255)
        case .magenta:
            return (255/255,0,255/255)
        case .light_magenta:
            return (211/255,56/255,211/255)
        case .cyan:
            return (0,255/255,255/255)
        case .light_cyan:
            return (51/255,187/255,200/255)
        case .white:
            return (255/255,255/255,255/255)
        case .light_white:
            return (203/255,204/255,205/255)
        case .default:
            return nil
        }
    }
}

/// The ANSI styles (self explanatory)
public enum TermStyle : Int, CaseIterable {
    case bold = 1
    case italic = 3
    case underline = 4
    case blink = 5
    case swap = 7
    case hide = 8
    case `default` = 0
}

public extension String {
    /// Creates a string with specified color and style
    /// - Parameters:
    ///   - color: the color to use
    ///   - style: the style to use
    /// - Returns: a string ready to be output in an ANSI terminal
    func apply(_ color: TermColor, style: TermStyle = .default) -> String {
        return "\u{001B}[\(color.rawValue + 30)m" + "\u{001B}[\(style.rawValue)m" + self
    }
    /// Creates a string with specified color and style
    /// - Parameters:
    ///   - color: the color to use
    ///   - styles: the styles to use
    /// - Returns: a string ready to be output in an ANSI terminal
    func apply(_ color: TermColor, styles: [TermStyle] = [.default]) -> String {
        let stylesStr = styles.map { "\u{001B}[\($0.rawValue)m" }.joined()
        return "\u{001B}[\(color.rawValue + 30)m" + stylesStr + self
    }
}

// MARK: Control

/// ANSI control sequence for hiding the cursor
public let HIDE_CURSOR = "\u{001B}[?25l"
/// ANSI control sequence for showing the cursor
public let SHOW_CURSOR = "\u{001B}[?25h"

/// ANSI control sequences
public enum TermControl : String {
    case CR = "\r"
    case NEWLINE = "\n"
    case UP = "\u{001B}[A"
    case DOWN = "\u{001B}[B"
    case FORWARD = "\u{001B}[C"
    case BACK = "\u{001B}[D"
    case CLEARSCR = "\u{001B}[2J"
    case CLEARFROMCSR = "\u{001B}[0J"
    case CLEARLINE = "\u{001B}[2K"
}

// MARK: Display Characters
/// Equivalence dictionary for constants used later
/// `line` variant
var line : [String:String] = [
    "empty" : " ",
    "point" : "─",
    "vert_left" : "│",
    "vert_right" : "│",
    "horz_top" : "─",
    "horz_bot" : "─",
    "bot_left" : "└",
    "top_right" : "┐",
    "top_left" : "┌",
    "bot_right" : "┘",
    "tick_right" : "┤",
    "tick_left" : "├",
    "tick_up": "┴",
    "tick_down" : "┬",
]

/// Equivalence dictionary for constants used later
/// `heavyline` variant
var heavyline : [String:String] = [
    "empty" : " ",
    "point" : "━",
    "vert_left" : "┃",
    "vert_right" : "┃",
    "horz_top" : "━",
    "horz_bot" : "━",
    "bot_left" : "┗",
    "top_right" : "┓",
    "top_left" : "┏",
    "bot_right" : "┛",
    "tick_right": "┫",
    "tick_left" : "┣",
    "tick_up": "┻",
    "tick_down" : "┳",
]

/// Equivalence dictionary for constants used later
/// `dots` variant
var dots : [String:String] = [
    "empty" : " ",
    "point" : "•",
]

/// Equivalence dictionary for constants used later
/// `crosses` variant
var crosses : [String:String] = [
    "empty" : " ",
    "point" : "x",
]

/// Equivalence dictionary for constants used later
/// `pluses` variant
var pluses : [String:String] = [
    "empty" : " ",
    "point" : "+",
]

/// Equivalence dictionary for constants used later
/// `stars` variant
var stars : [String:String] = [
    "empty" : " ",
    "point" : "*",
]

/// Possible styles for the graph
public enum DisplayStyle : CaseIterable {
    case line
    case heavyline
    case dots
    case crosses
    case pluses
    case stars
}

/// Possible symbols to use in the graph
public enum DisplaySymbol : String, CaseIterable {
    case empty
    case point
    case vert_left
    case vert_right
    case horz_top
    case horz_bot
    case bot_left
    case top_right
    case top_left
    case bot_right
    case tick_right
    case tick_left
    case tick_up
    case tick_down

    /// Adapts the symbol to a style, and generates a string ready for output
    /// - Parameter s: the style to use
    /// - Returns: the string to output
    public func withStyle(_ s: DisplayStyle) -> String {
        let style : [String:String]
        switch(s) {
        case .line:
            style = line
        case .heavyline:
            style = heavyline
        case .dots:
            style = dots
        case .crosses:
            style = crosses
        case .pluses:
            style = pluses
        case .stars:
            style = stars
        }
        
        return style[self.rawValue] ?? style[DisplaySymbol.empty.rawValue]!
    }
    
    /// Adapts the symbol to a style, and generates a character ready for output
    /// - Parameter s: the style to use
    /// - Returns: the character to output
    public func cWithStyle(_ s: DisplayStyle) -> Character {
        let style : [String:String]
        switch(s) {
        case .line:
            style = line
        case .heavyline:
            style = heavyline
        case .dots:
            style = dots
        case .crosses:
            style = crosses
        case .pluses:
            style = pluses
        case .stars:
            style = stars
        }
        
        let str = style[self.rawValue] ?? style[DisplaySymbol.empty.rawValue]!
        return str.first!
    }

}
