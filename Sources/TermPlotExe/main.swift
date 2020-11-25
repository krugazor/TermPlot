import Foundation
import TermPlot
// import SwiftLoggerClient

// doDemo()
// doSeriesDemo()

// SwiftLogger.setupForHTTP(URL(string: "http://localhost:8080")!, appName: "TermPlot")

let live = LiveSeriesWindow(tick: 1, total: 80, input: FileHandle.standardInput)
live.start()

RunLoop.current.run(until: Date.distantFuture)

