#if os(Linux)
import Glibc
#endif

import Foundation
// import SwiftLoggerClient

public struct TermCharacter {
    var char : Character
    var color : TermColor
    var styles : [TermStyle]
    
    public init(_ c: Character = " ", color col : TermColor = .default, styles s: [TermStyle] = [.default]) {
        char = c
        color = col
        styles = s
    }
}

public class TermWindow {
    // Only one window is allowed
    static fileprivate var _window : TermWindow?
    static public var `default` : TermWindow {
        if let w = _window { return w }
        let w = TermWindow()
        _window = w
        return w
    }
    
    fileprivate var screenLock : NSLock = NSLock()
    fileprivate var originalSettings : termios?
    fileprivate var setup = false // until we do anything, no need to reserve space
    public private(set) var rows: Int
    public private(set) var cols: Int
    fileprivate var currentBox : (cols: Int, rows: Int) = (0,0) // ditto
    fileprivate var cursorPosition : (x: Int, y: Int) = (0,0)
    
    init() {
        //        #warning("remove")
        //        SwiftLogger.setupForHTTP(URL(string: "http://localhost:8080")!, appName: "TermPlot")
        
        rows = TermHandler.shared.rows
        cols = TermHandler.shared.cols
        
        self.clearScreen()
        TermHandler.shared.windowResizedAction = { thndlr in
            self.rows = TermHandler.shared.rows
            self.cols = TermHandler.shared.cols
            self.boxScreen()
        }
    }
    
    func setupTTY() {
        var stermios = termios()
        tcgetattr(STDOUT_FILENO, &stermios)
        originalSettings = stermios
        #if os(Linux)
        let newcflags : UInt32 = stermios.c_lflag & ~UInt32(ECHO)
        #else
        let newcflags : UInt = stermios.c_lflag & ~UInt(ECHO)
        #endif
        stermios.c_lflag = newcflags
        tcsetattr(STDOUT_FILENO, TCSAFLUSH, &stermios)
        
        // restore when the program ends abruptly
        _ = signal(SIGINT) { sig in
            TermWindow.default.restoreTTY()
            exit(SIGINT)
        }
        _ = signal(SIGKILL) { sig in
            TermWindow.default.restoreTTY()
            exit(SIGKILL)
        }
        
        stdout("\u{001B}[?1049h")
        stdout(HIDE_CURSOR)
        
        // In order to avoid erasing some of the previous buffer, add as many lines as the screen is high
        for _ in 0..<rows {
            stdout(TermControl.NEWLINE.rawValue)
        }
        
        setup = true
    }
    
    func restoreTTY() {
        stdout(SHOW_CURSOR)
        stdout("\u{001B}[?1049l")
        
        if var set = originalSettings {
            tcsetattr(STDOUT_FILENO, TCSAFLUSH, &set)
        }
    }
    
    public func moveCursorRight(_ amount: Int) {
        TermHandler.shared.moveCursorRight(amount)
        cursorPosition.x += 1
    }
    
    public func moveCursorLeft(_ amount: Int) {
        TermHandler.shared.moveCursorLeft(amount)
        cursorPosition.x -= 1
    }
    
    public func moveCursorUp(_ amount: Int) {
        TermHandler.shared.moveCursorUp(amount)
        cursorPosition.y -= 1
    }
    
    public func moveCursorDown(_ amount: Int) {
        TermHandler.shared.moveCursorDown(amount)
        cursorPosition.y += 1
    }
    
    public func clearScreen() {
        screenLock.lock()
        if !setup { setupTTY() }
        TermHandler.shared.moveCursor(toX: 1, y: 1)
        stdout(TermControl.CLEARFROMCSR.rawValue)
        
        currentBox.cols = self.cols
        currentBox.rows = self.rows
        screenLock.unlock()
    }
    
    public func boxScreen() {
        TermHandler.shared.set(TermColor.default, style: TermStyle.default)
        clearScreen()
        
        TermHandler.shared.moveCursor(toX: 1, y: 1)
        // top line
        for _ in 1...cols { stdout(DisplaySymbol.horz_top.withStyle(.line)) }
        for y in 2...(rows-1) {
            TermHandler.shared.moveCursor(toX: 1, y: y)
            stdout(DisplaySymbol.vert_left.withStyle(.line))
            TermHandler.shared.moveCursor(toX: cols, y: y)
            stdout(DisplaySymbol.vert_left.withStyle(.line))
        }
        TermHandler.shared.moveCursor(toX: 1, y: rows)
        for _ in 1...cols { stdout(DisplaySymbol.horz_top.withStyle(.line)) }
    }
    
    public func requestBuffer(_ handler: (inout [[Character]])->Void) {
        var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols-2), count: rows-2)
        handler(&buffer)
        
        boxScreen()
        
        TermHandler.shared.moveCursor(toX: 2, y: 2)
        var crow = 2
        for row in buffer {
            for char in row {
                stdout(String(char))
            }
            crow += 1
            TermHandler.shared.moveCursor(toX: 2, y: crow)
       }
    }
    
    public func requestStyledBuffer(_ handler: (inout [[TermCharacter]])->Void) {
        var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols-2), count: rows-2)
        handler(&buffer)
        
        boxScreen()
        
        TermHandler.shared.moveCursor(toX: 2, y: 2)
        var crow = 2
        for row in buffer {
            for char in row {
                TermHandler.shared.set(char.color, styles: char.styles)
                stdout(String(char.char))
            }
            crow += 1
            TermHandler.shared.moveCursor(toX: 2, y: crow)
       }
    }

}
