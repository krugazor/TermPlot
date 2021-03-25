import Foundation
#if os(Linux)
import Glibc
#endif

#if os(macOS)
/// Use to determine the terminal size (columns and rows)
/// not very reliable
/// - Returns: a tuple containing the columns and rows
public func TermSize() -> (cols: Int, rows: Int) {
    let task = Process()
    task.launchPath = "/bin/stty"
    task.arguments = ["-a"]
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let string = String(data: data, encoding: String.Encoding.utf8),
       let firstLine = string.components(separatedBy: CharacterSet.newlines).first {
        let details = firstLine.components(separatedBy: ";").map({ $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) })
        // we should now have
        // ["speed 9600 baud", "46 rows", "142 columns", ""] or something like that
        var rows : Int?
        var cols : Int?
        for d in details {
            if d.hasSuffix("rows") { rows = Int(d.components(separatedBy: CharacterSet.whitespaces).first ?? "")}
            else if d.hasSuffix("columns") { cols = Int(d.components(separatedBy: CharacterSet.whitespaces).first ?? "")}
        }
        return (cols ?? 80, rows ?? 43)
    } else {
        return (80,43)
    }
}
#endif

/// Use to determine the terminal size (columns and rows)
/// better, still doesn't work in debugger console
/// - Returns: a tuple containing the columns and rows
public func TermSize2() -> (cols: Int, rows: Int) {
    var size : winsize = winsize()
    #if os(Linux)
    let err = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size)
    #else
    let err = ioctl(STDOUT_FILENO, TIOCGWINSZ, &size)
    #endif
    return (Int(size.ws_col), Int(size.ws_row))
}

/// Function called by the signal handler
/// - Parameter sig: the incoming signal
fileprivate func signalHandler(_ sig: Int32) {
    let(c,r) = TermSize2()
    TermHandler.shared.cols = c
    TermHandler.shared.rows = r
    TermHandler.shared.windowResizedAction?(TermHandler.shared)
}

/// Function used to print to console, without the frills
/// - Parameter s: the string to put out
func stdout(_ s: String) {
    let out = FileHandle.standardOutput
    out.write(s.data(using: .utf8)!)
}

/// Low level class used to handle everything ANSI
public class TermHandler {
    /// columns in the current instance
    public fileprivate(set) var cols  = 80
    /// lines in the current instance
    public fileprivate(set) var rows = 43
    /// block to call in the event of window resizing
    /// not the most elegant, but I cannot have labels on the arguments
    var windowResizedAction : ((TermHandler)->Void)?
    /// the "v-sync" lock
    var screenLock = NSLock()
    
    /// private-ish initializer for the singleton
    init() {
        let(c,r) = TermSize2()
        if c == 0 && r == 0 { // debug weirdness
            cols = 80
            rows = 24
        } else {
            cols = c
            rows = r
        }
        _ = signal(SIGWINCH, signalHandler)
    }
    
    ///
    /// Action handler signature.
    ///
    public typealias SigActionHandler = @convention(c)(Int32) -> Void
    
    
    // MARK: Class Methods
    
    ///
    /// Trap an operating system signal.
    ///
    /// - Parameters:
    ///        - signal:    The signal to catch.
    ///        - action:    The action handler.
    ///
    public class func trap(signal: Int32, action: @escaping SigActionHandler) {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
        _ = withUnsafePointer(to: &signalAction) { actionPointer in
            sigaction(signal, actionPointer, nil)
        }
        #elseif os(Linux)
        var sigAction = sigaction()
        sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
        _ = sigaction(signal, &sigAction, nil)
        #endif
    }
    
    /// private singleton instance
    static var _instance : TermHandler?
    /// public shared singleton
    static public var shared : TermHandler {
        if let i = _instance { return i }
        let i = TermHandler()
        _instance = i
        return i
    }
    
    // MARK: utility functions
    /// Moves the cursor down and to the beginning of the line (may not be supported)
    /// - Parameter amount: the delta
    public func moveCursorNewline() {
        stdout(TermControl.NEWLINESTART.rawValue)
    }
    
    /// Moves the cursor right by a certain amount
    /// - Parameter amount: the delta
    public func moveCursorRight(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.FORWARD.rawValue)
        }
    }

    /// Moves the cursor left by a certain amount
    /// - Parameter amount: the delta
    public func moveCursorLeft(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.BACK.rawValue)
        }
    }
    
    /// Moves the cursor down by a certain amount
    /// - Parameter amount: the delta
    public func moveCursorDown(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.DOWN.rawValue)
        }
    }
    
    /// Moves the cursor up by a certain amount
    /// - Parameter amount: the delta
    public func moveCursorUp(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.UP.rawValue)
        }
    }
    
    /// Moves the cursor to specific coordinates. Warning! 1-based
    /// - Parameters:
    ///   - toX: x position
    ///   - y: y position
    public func moveCursor(toX: Int, y: Int) {
        let cmd = "\u{001B}[\(y);\(toX)H"
        stdout(cmd)
    }
    
    /// variant of (out)put with an agnostic string
    /// - Parameter s: the text to output
    public func put(s: String) {
        stdout(s)
    }
    
    /// variant of (out)put with an specific style
    /// - Parameter s: the text to output
    /// - Parameter color: the color to use
    /// - Parameter style: the style to use
    public func put(s: String, color: TermColor, style: TermStyle) {
        stdout(s.apply(color, style: style))
    }
    
    /// variant of (out)put with an specific style
    /// - Parameter s: the text to output
    /// - Parameter color: the color to use
    /// - Parameter styles: the styles to use
    public func put(s: String, color: TermColor, styles: [TermStyle]) {
        stdout(s.apply(color, styles: styles))
    }
    
    /// changes the style for the next output
    /// - Parameter color: the color to use
    /// - Parameter style: the style to use
    public func set(_ color: TermColor, style: TermStyle) {
        stdout("".apply(color, style: style))
    }
    
    /// changes the style for the next output
    /// - Parameter color: the color to use
    /// - Parameter style: the set of styles to use
    public func set(_ color: TermColor, styles: [TermStyle]) {
        stdout("".apply(color, styles: styles))
    }
    
    /// Locks the v-blank
    public func lock() { screenLock.lock() }
    /// Unlocks the v-blank
    public func unlock() {screenLock.unlock() }
}

// For debug purposes
extension Array where Element == TermCharacter {
    public func debugString() -> String {
        return self.map({ String($0.char) }).joined(separator: "")
    }
}

extension Array where Element == [TermCharacter] {
    public func debugString() -> String {
        return self.map( { $0.debugString() }).joined(separator: "\n")
    }
}
