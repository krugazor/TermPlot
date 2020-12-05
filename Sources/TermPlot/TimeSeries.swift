import Foundation

/// Series variant based ton timer ticks
public class TimeSeriesWindow : StandardSeriesWindow {
    /// the timer that will repeatedly call the input block
    var sourceTimer : Timer?
    /// the block in charge of getting new values
    var sourceBlock : ()->Double
    
    /// Neutralized public initializer
    /// - Parameters:
    ///   - tick: useless
    ///   - total: useless
    public override init(tick: TimeInterval, total: TimeInterval) {
        fatalError("You probably want to use StandardSeriesWindow, if you don't provide a source")
    }

    /// Public initializer
    /// - Parameters:
    ///   - tick: width of an x-interval, time between ticks
    ///   - total: range of the x-axis
    ///   - source: the block to call every tick for new values
    public init(tick: TimeInterval, total: TimeInterval, source: @escaping ()->Double) {
        sourceBlock = source
        defer {
            computeRowStyles()
        }
        
        super.init(tick: tick, total: total)
    }
    
    /// Starts the display and tick
    public override func start() {
        sourceTimer = Timer.scheduledTimer(withTimeInterval: timeTick, repeats: true, block: { (timer) in
            self.values.append(self.sourceBlock())
            while self.values.count > self.timeCount {
                self.values.remove(at: 0)
            }
            self.display()
        })
    }
    
    /// Stops the tick
    public override func stop() {
        sourceTimer?.invalidate()
        sourceTimer = nil
    }
    
}
