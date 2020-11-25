import Foundation
// import SwiftLoggerClient

public class LiveSeriesWindow : TimeSeriesWindow {
    public override init(tick: TimeInterval, total: TimeInterval, source: @escaping () -> Double) {
        print("You probably wanted to use TimeSeriesWindow")
        exit(-1)
    }
    
    public init(tick: TimeInterval, total: TimeInterval, input: FileHandle) {
        var buffer = ""
        NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification,
                                               object: input,
                                               queue: nil) { notification in
            if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
               let dataStr = String(data: data, encoding: .utf8) {
                buffer += dataStr
            }
            input.readInBackgroundAndNotify()
        }
        input.readInBackgroundAndNotify()
        super.init(tick: tick, total: total) {
            let notLast = CharacterSet.newlines.contains(buffer.unicodeScalars.last ?? " ")
            var lines = buffer.components(separatedBy: CharacterSet.newlines)
            if notLast { lines = lines.dropLast().filter({ !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }) }
            else { lines = lines.filter({ !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }) }
            var output = 0.0
            
            var first : Double? = nil
            while first == nil && !lines.isEmpty {
                first = Double(lines.first!)
                lines = Array(lines.dropFirst())
            }
            
            if let first = first {
                output = first
            }
            
            if !lines.isEmpty {
                buffer = lines.joined(separator: "\n")
            } else {
                buffer = ""
            }
            
            return output
        }
    }
}
