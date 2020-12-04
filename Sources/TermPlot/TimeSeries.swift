import Foundation

public class TimeSeriesWindow : StandardSeriesWindow {
    var sourceTimer : Timer?
    var sourceBlock : ()->Double
    
    public override init(tick: TimeInterval, total: TimeInterval) {
        fatalError("You probably want to use StandardSeriesWindow, if you don't provide a source")
    }

    public init(tick: TimeInterval, total: TimeInterval, source: @escaping ()->Double) {
        sourceBlock = source
        defer {
            computeRowStyles()
        }
        
        super.init(tick: tick, total: total)
    }
    
    public override func start() {
        sourceTimer = Timer.scheduledTimer(withTimeInterval: timeTick, repeats: true, block: { (timer) in
            self.values.append(self.sourceBlock())
            while self.values.count > self.timeCount {
                self.values.remove(at: 0)
            }
            self.display()
        })
    }
    
    public override func stop() {
        sourceTimer?.invalidate()
        sourceTimer = nil
    }
    
}
