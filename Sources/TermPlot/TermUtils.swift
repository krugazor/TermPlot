import Foundation
#if os(Linux)
import Glibc
#endif

// not very reliable
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

// better, still doesn't work in debugger stdout
public func TermSize2() -> (cols: Int, rows: Int) {
    var size : winsize = winsize()
    #if os(Linux)
    let err = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size)
    #else
    let err = ioctl(STDOUT_FILENO, TIOCGWINSZ, &size)
    #endif
    return (Int(size.ws_col), Int(size.ws_row))
}

fileprivate func signalHandler(_ sig: Int32) {
    let(c,r) = TermSize2()
    TermHandler.shared.cols = c
    TermHandler.shared.rows = r
    TermHandler.shared.windowResizedAction?(TermHandler.shared)
}

func stdout(_ s: String) {
    let out = FileHandle.standardOutput
    out.write(s.data(using: .utf8)!)
}

public class TermHandler {
    public fileprivate(set) var cols  = 80
    public fileprivate(set) var rows = 43
    var windowResizedAction : ((TermHandler)->Void)? // not the most elegant, but I cannot have labels on the arguments
    
    init() {
        let(c,r) = TermSize2()
        cols = c
        rows = r
        
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
    
    static var _instance : TermHandler?
    static var shared : TermHandler {
        if let i = _instance { return i }
        let i = TermHandler()
        _instance = i
        return i
    }
    
    // MARK: utility functions
    func moveCursorRight(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.FORWARD.rawValue)
        }
    }
    
    func moveCursorLeft(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.BACK.rawValue)
        }
    }
    
    func moveCursorDown(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.DOWN.rawValue)
        }
    }
    
    func moveCursorUp(_ amount: Int) {
        for _ in 0..<amount {
            stdout(TermControl.UP.rawValue)
        }
    }
    
    // Warning! 1-based
    func moveCursor(toX: Int, y: Int) {
        let cmd = "\u{001B}[\(y);\(toX)H"
        stdout(cmd)
    }
    
    func put(s: String) {
        stdout(s)
    }
    
    func put(s: String, color: TermColor, style: TermStyle) {
        stdout(s.apply(color, style: style))
    }
    
    func set(_ color: TermColor, style: TermStyle) {
        stdout("".apply(color, style: style))
    }
    
    func set(_ color: TermColor, styles: [TermStyle]) {
        stdout("".apply(color, styles: styles))
    }
    
}
