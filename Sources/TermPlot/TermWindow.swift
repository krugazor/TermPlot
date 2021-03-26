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
    public internal(set) var rows: Int {
        didSet {
            rowsDidChange()
        }
    }
    /// number of columns in the buffer
    public internal(set) var cols: Int {
        didSet {
            colsDidChange()
        }
    }
    /// remnants from earlier experiments about lessening the number of redraws
    fileprivate var currentBox : (cols: Int, rows: Int) = (0,0) // ditto
    /// remnants from earlier experiments about lessening the number of redraws
    fileprivate var cursorPosition : (x: Int, y: Int) = (0,0)
    
    /// Box styles for public consumption
    /// - none empty border
    /// - simple dashes and pipes (simple line)
    /// - ticked (will do its best to add meaningful tick marks)
    public enum TermBoxType {
        case none
        case simple
        case ticked
    }

    /// unique ID to make sure we're talking about the same windows
    let wid = UUID()

    /// if a window is embedded in another
    var embeddedIn: TermWindow?

    /// Function called when screen size changes
    func rowsDidChange() {
        // for override purposes
    }
    
    /// Function called when screen size changes
    func colsDidChange() {
        // for override purposes
    }
    
    /// function used to determine the width/height we should give our children windows
    /// as it mostly is for multiterms, this will likely return the size of the terminal
    /// will need to be overridden
    ///
    /// - Parameter for : the term to look for in children
    ///
    /// - Returns: the expected size this window will occupy
    func size(for: TermWindow) -> (width: Int, height: Int) {
        if let emi = embeddedIn {
            return emi.size(for: self) // pass the buck upstrairs
        } else {
            return (TermHandler.shared.rows,TermHandler.shared.cols)
        }
    }

    /// function used to determine the width/height we should give our children windows
    /// as it mostly is for multiterms, this will likely return the size of the terminal
    /// will need to be overridden
    ///
    /// - Parameter for : the term uuid to look for in children
    ///
    /// - Returns: the expected size this window will occupy
    func size(for: UUID) -> (width: Int, height: Int) {
        if let emi = embeddedIn {
            return emi.size(for: self) // pass the buck upstrairs
        } else {
            return (TermHandler.shared.rows,TermHandler.shared.cols)
        }
    }


    /// Default initializer
    init(embedIn: TermWindow? = nil) {
        embeddedIn = embedIn

        if let emi = embedIn {
            (rows,cols) = emi.size(for: wid)
        } else {
            rows = TermHandler.shared.rows
            cols = TermHandler.shared.cols
            self.clearScreen()
        }
        TermHandler.shared.windowResizedAction = { thndlr in
            (self.rows, self.cols) = self.size(for: self)
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
                TermHandler.shared.unlock()
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
    
    /// Box type around the screen
    /// - none is none
    /// - simple is just dashes and pipes (straight lines all the way)
    /// - ticked is simple + tick marks
    public enum BoxType {
        case none
        case simple
        case ticked([(col: Int, str: String)],[(row: Int, str: String)])
    }
    
    /// Draws a box around the screen
    /// - Parameter style: the box style (default `.simple`)
    public func boxScreen(_ style: BoxType = .simple) {
        switch style {
        case .none:
            return
        default:
            break
        } // the issue with enums that have associated values is you can't test them with == anymore
        
        TermHandler.shared.lock()
        TermHandler.shared.set(TermColor.default, style: TermStyle.default)
        if embeddedIn == nil { clearScreen() }
        
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
        
        switch style {
        case .ticked(let colTicks, let rowTicks):
            for (col,str) in colTicks {
                if col + str.count >= self.cols { break } // sorry, won't go there
                TermHandler.shared.moveCursor(toX: col, y: self.rows)
                stdout(DisplaySymbol.tick_up.withStyle(.line)+str.apply(.default, style: .default))
            }
            for (row,str) in rowTicks {
                if row >= rows { break } // ditto
                TermHandler.shared.moveCursor(toX: 1, y: row)
                stdout(DisplaySymbol.tick_left.withStyle(.line)+str.apply(.default, style: .default))
            }
            break
        default:
            break
        } // ditto
    }
    
    /// Draws the contents of a buffer to screen (blit function)
    /// - Parameters:
    ///   - buffer: the buffer to output
    ///   - offset: the offset at which to start on screen
    func draw(_ buffer: [[Character]], offset: (Int,Int) = (0,0), clearSkip: Bool = true) {
        TermHandler.shared.lock()
        TermHandler.shared.moveCursor(toX: offset.0, y: offset.1)
        var crow = offset.1+1
        for row in buffer {
            for char in row {
                if !clearSkip || char != " " {
                    stdout(String(char))
                } else {
                    TermHandler.shared.moveCursorRight(1)
                }
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
    func draw(_ buffer: [[TermCharacter]], offset: (Int,Int) = (0,0), clearSkip: Bool = true) {
        TermHandler.shared.lock()
        TermHandler.shared.moveCursor(toX: 1+offset.0, y: 1+offset.1)
        var crow = offset.1+1
        for row in buffer {
            for char in row {
                if !clearSkip || char.char != " " {
//                    TermHandler.shared.set(char.color, styles: char.styles)
//                    stdout(String(char.char))
                    TermHandler.shared.put(s: String(char.char), color: char.color, styles: char.styles)
                } else {
                    TermHandler.shared.moveCursorRight(1)
                }
           }
            crow += 1
            TermHandler.shared.moveCursor(toX: offset.0+1, y: crow)
        }
        TermHandler.shared.set(.default, style: .default)
        TermHandler.shared.unlock()
    }
    
    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// In this particular case, does nothing, as regular windows don't have subwindows
    /// - Parameters:
    ///   - for: the window requesting a buffer
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestBuffer(for sub: TermWindow, box: BoxType = .simple, _ handler: (inout [[Character]])->Void) {
        switch box {
        case .none:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        default:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols-2), count: rows-2)
            handler(&buffer)

            boxScreen(box)

            draw(buffer, offset: (1,1))
        }
    }

    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// In this particular case, does nothing, as regular windows don't have subwindows
    /// - Parameters:
    ///   - for: the window requesting a buffer
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestStyledBuffer(for sub: TermWindow, box: BoxType = .simple, _ handler: (inout [[TermCharacter]])->Void) {
        switch box {
        case .none:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        default:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols-2), count: rows-2)
            handler(&buffer)

            boxScreen(box)
            draw(buffer, offset: (1,1))
        }
    }

    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// - Parameters:
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestBuffer(box: BoxType = .simple, _ handler: (inout [[Character]])->Void) {
        if let emi = embeddedIn {
            emi.requestBuffer(for: self, box: box, handler)
            return
        }
        switch box {
        case .none:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        default:
            var buffer = [[Character]](repeating: [Character](repeating: " ", count: cols-2), count: rows-2)
            handler(&buffer)
            
            boxScreen(box)
            
            draw(buffer, offset: (1,1))
        }
    }
    
    /// Reserve and callback mechanic to draw on screen: a buffer is generated according to the current size, then filled by the block, then blit
    /// - Parameters:
    ///   - box: should we box the screen?
    ///   - handler: the block that will fill the buffer
    public func requestStyledBuffer(box: BoxType = .simple, _ handler: (inout [[TermCharacter]])->Void) {
        if let emi = embeddedIn {
            emi.requestStyledBuffer(for: self, box: box, handler)
            return
        }
       switch box {
        case .none:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols), count: rows)
            handler(&buffer)

            draw(buffer)
        default:
            var buffer = [[TermCharacter]](repeating: [TermCharacter](repeating: TermCharacter(), count: cols-2), count: rows-2)
            handler(&buffer)
            
            boxScreen(box)
            draw(buffer, offset: (1,1))
        }
    }

}
