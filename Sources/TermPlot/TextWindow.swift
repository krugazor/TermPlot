import Foundation

/// Text display window, with styles
public class TextWindow : TermWindow {
    /// Text buffer
    /// TODO: trim string above a certain size
    var textBuffer : NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    /// Current box style
    public var boxStyle : TermBoxType = .simple
    
    /// Current decomposition of the text
    var textData : [(TermColor,TermStyle,String)] = []
    
    public override init(embedIn: TermWindow? = nil) { // to keep the compiler happy
        super.init(embedIn: embedIn)
    }
    
    /// Adds a new line to the buffer
    public func newline() {
        textBuffer.append(NSAttributedString(string: "\n"))
        textData = mapAttributes(textBuffer)
        display()
    }
    
    /// Add a default style string to the buffer
    /// - Parameter txt: the string to add
    public func add(_ txt: String) {
        textBuffer.append(NSAttributedString(string: txt))
        textData = mapAttributes(textBuffer)
        display()
    }

    /// Add a styled string to the buffer
    /// - Parameter txt: the string to add
    public func add(_ txt: NSAttributedString) {
        textBuffer.append(txt)
        textData = mapAttributes(textBuffer)
        display()
    }
    // MARK: -

    override func colsDidChange() {
        display()
    }
    
    override func rowsDidChange() {
        display()
    }
    
    // MARK: -
    /// Main function: displays the text on screen
    func display() {
        if embeddedIn == nil { clearScreen() }
        
        let cboxStyle: BoxType
        switch boxStyle {
        case .none: cboxStyle = .none
        case .simple: cboxStyle = .simple
        case .ticked: cboxStyle = .simple
        }
        requestStyledBuffer(box: cboxStyle) { buffer in
            let height = buffer.count
            let width = buffer[0].count
            let displayData = fit(textData, in: width, lines: height)
            for i in 0..<buffer.count {
                buffer[i] = displayData[i]
            }
        }
    }
}
