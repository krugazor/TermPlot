#if os(Linux)
import Glibc
#endif

import Foundation

/// Basic "pixel" like structure
public struct TermCharacter {
    /// the character
    var char : Character
    /// the color
    var color : TermColor
    /// the styles
    var styles : [TermStyle]
    
    /// Initializer with defaults built-in
    /// - Parameters:
    ///   - c: a character
    ///   - col: a color
    ///   - s: styles to use
    public init(_ c: Character = " ", color col : TermColor = .default, styles s: [TermStyle] = [.default]) {
        char = c
        color = col
        styles = s
    }
}

/// "Screen" or "buffer" analog for output. Will be used by all descendants to draw things in the terminal
public class TermWindow {
    // Only one window should be allowed
    /// Singleton variable
    static fileprivate var _window : TermWindow?
    /// Singleton shared variable
    static public var `default` : TermWindow {
        if let w = _window { return w }
        let w = TermWindow()
        _window = w
        return w
    }
    
    /// clear screen lock
    fileprivate var screenLock : NSLock = NSLock()
    /// settings grabbed from the terminal when the instance started
    fileprivate var originalSettings : termios?
    /// have we setup the TTY?
    fileprivate var setup = false // until we do anything, no need to reserve space
    /// number of rows in the buffer
    public private(set) var rows: Int {
        didSet {
            rowsDidChange()
        }
    }
    /// number of columns in the buffer
    public private(set) var cols: Int {
        didSet {
            colsDidChange()
        }
    }
    /// remnants from earlier experiments about lessening the number of redraws
    fileprivate var currentBox : (cols: Int, rows: Int) = (0,0) // ditto
    /// remnants from earlier experiments about lessening the number of redraws
    fileprivate var cursorPosition : (x: Int, y: Int) = (0,0)
    
    /// Function called when screen size changes
    func rowsDidChange() {
        // for override purposes
    }
    
    /// Function called when screen size changes
    func colsDidChange() {
        // for override purposes
    }
    
    /// Default initializer
    init() {
        rows = TermHandler.shared.rows
        cols = TermHandler.shared.cols
        
        self.clearScreen()
        TermHandler.shared.windowResizedAction = { thndlr in
            self.rows = TermHandler.shared.rows
            self.cols = TermHandler.shared.cols
        }
    }
    
    /// Sets the ANSI terminal up (hides the cursor, clears the screen, etc)
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
            TermWindow.default.restoreTTY {
                exit(SIGINT)
            }
        }
        _ = signal(SIGKILL) { sig in
            TermWindow.default.restoreTTY {
                exit(SIGKILL)
            }
        }
        
        stdout("\u{001B}[?1049h")
        stdout(HIDE_CURSOR)
        
        // In order to avoid erasing some of the previous buffer, add as many lines as the screen is high
        for _ in 0..<rows {
            stdout(TermControl.NEWLINE.rawValue)
        }
        
        setup = true
    }
    
    /// Restores the TTY to previous settings (before the program grabbed it)
    /// - Parameter then: the block to call once the settings are restored
    func restoreTTY(then: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            TermHandler.shared.lock()
            stdout(SHOW_CURSOR)
            stdout("\u{001B}[?1049l")
            DispatchQueue.main.async {
                if var set = self.originalSettings {
                    #if os(Linux)
                    let newcflags : UInt32 = set.c_lflag | UInt32(ECHO)
                    #else
                    let newcflags : UInt = set.c_lflag | UInt(ECHO)
                    #endif
                    set.c_lflag = newcflags
                    tcsetattr(STDOUT_FILENO, TCSAFLUSH, &set)
                } else {
                    // restore echo
                    var stermios = termios()
                    tcgetattr(STDOUT_FILENO, &stermios)
                    #if os(Linux)
                    let newcflags : UInt32 = stermios.c_lflag | UInt32(ECHO)
                    #else
                    let newcflags : UInt = stermios.c_lflag | UInt(ECHO)
                    #endif
                    stermios.c_lflag = newcflags
                    tcsetattr(STDOUT_FILENO, TCSAFLUSH, &stermios)
                }
 
                stdout("exiting\n".apply(.default, styles: [.default]))
                then()
            }
        }
    }
    
    /// Publicly exposed function to move the cursor right
    /// - Parameter amount: number of steps
    public func moveCursorRight(_ amount: Int) {
        TermHandler.shared.moveCursorRight(amount)
        cursorPosition.x += 1
    }
    
    /// Publicly exposed function to move the cursor left
    /// - Parameter amount: number of steps
    public func moveCursorLeft(_ amount: Int) {
        TermHandler.shared.moveCursorLeft(amount)
        cursorPosition.x -= 1
    }
    
    /// Publicly exposed function to move the cursor up
    /// - Parameter amount: number of steps
    public func moveCursorUp(_ amount: Int) {
        TermHandler.shared.moveCursorUp(amount)
        cursorPosition.y -= 1
    }
    
    /// Publicly exposed function to move the cursor down
    /// - Parameter amount: number of steps
    public func moveCursorDown(_ amount: Int) {
        TermHandler.shared.moveCursorDown(amount)
        cursorPosition.y += 1
    }
    
    /// Clears the screen and sets the TTY up if necessary
    public func clearScreen() {
        screenLock.lock()
        if !setup { setupTTY() }
        TermHandler.shared.moveCursor(toX: 1, y: 1)
        stdout(TermControl.CLEARFROMCSR.rawValue)
        
        currentBox.cols = self.cols
        currentBox.rows = self.rows
        screenLock.unlock()
    }
    
    /// Draws a box around the screen
    public func boxScreen() {
        TermHandler.shared.lock()
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
        TermHandler.shared.set(.default, style: .default)
        TermHandler.shared.unlock()
    }
    
    /// Draws the contents of a buffer to screen (blit function)
    /// - Parameters:
    ///   - buffer: the buffer to output
    ///   - offset: the offset at which to start on screen
    func draw(_ buffer: [[Character]], offset: (Int,Int) = (0,0)) {
        TermHandler.shared.lock()
        TermHandler.shared.moveCursor(toX: offset.0, y: offset.1)
        var crow = offset.1+1
        for row in buffer {
            for char in row {
                stdout(String(char))
            }
            crow += 1
            TermHandler.shared.moveCursor(toX: offset.0+1, y: crow)
        }
        TermHandler.shared.set(.default, style: .default)
        TermHandler.shared.unlock()
    }
    
    /// Draws the contents of a buffer to screen (blit function)
    /// - Parameters:
    ///   - buffer: the buffer to output
    ///   - offset: the offset at which to start on screen
    func draw(_ buffer: [[TermCharacter]], offset: (Int,Int) = (0,0)) {
        TermHandler.shared.lock()
        TermHandler.shared.moveCursor(toX: 1+offset.0, y: 1+offset.1)
        var crow = offset.1+1
        for row in buffer {
            for char in row {
                TermHandler.shared.set(char.color, styles: char.styles)
                stdout(String(char.char))
            }
            crow += 1
            TermHandler.shared.moveCursor(toX: offset.0+1, y: crow)
        }
        TermHandler.shared.set(.default, style: .default)
        TermHandler.shared.unlock()
    }
    
    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// - Parameters:
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestBuffer(box: Bool = true, _ handler: (inout [[Character]])->Void) {
        if box {
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols-2), count: rows-2)
            handler(&buffer)
            
            boxScreen()
            
            draw(buffer, offset: (1,1))
        } else {
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        }
    }
    
    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// - Parameters:
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestStyledBuffer(box: Bool = true, _ handler: (inout [[TermCharacter]])->Void) {
        if box {
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols-2), count: rows-2)
            handler(&buffer)
            
            boxScreen()
            draw(buffer, offset: (1,1))
        } else {
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        }
    }

}
