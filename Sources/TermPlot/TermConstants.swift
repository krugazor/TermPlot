import Foundation

// MARK: Colors
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
}

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
    func apply(_ color: TermColor, style: TermStyle = .default) -> String {
        return "\u{001B}[\(color.rawValue + 30)m" + "\u{001B}[\(style.rawValue)m" + self
    }
    func apply(_ color: TermColor, styles: [TermStyle] = [.default]) -> String {
        let stylesStr = styles.map { "\u{001B}[\($0.rawValue)m" }.joined()
        return "\u{001B}[\(color.rawValue + 30)m" + stylesStr + self
    }
}

// MARK: Control

public let HIDE_CURSOR = "\u{001B}[?25l"
public let SHOW_CURSOR = "\u{001B}[?25h"

public enum TermControl : String {
    case CR = "\r"
    case NEWLINE = "\n"
    case UP = "\u{001B}[A"
    case DOWN = "\u{001B}[B"
    case FORWARD = "\u{001B}[C"
    case BACK = "\u{001B}[D"
    case CLEARSCR = "\u{001B}[2J"
    case CLEARFROMCSR = "\u{001B}[0J"
}

// MARK: Display Characters
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
]

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
    "tick_right": "┫"
]

var dots : [String:String] = [
    "empty" : " ",
    "point" : "•",
]

var crosses : [String:String] = [
    "empty" : " ",
    "point" : "x",
]

var pluses : [String:String] = [
    "empty" : " ",
    "point" : "+",
]

var stars : [String:String] = [
    "empty" : " ",
    "point" : "*",
]

public enum DisplayStyle : CaseIterable {
    case line
    case heavyline
    case dots
    case crosses
    case pluses
    case stars
}

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
}
