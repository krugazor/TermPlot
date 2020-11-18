import Foundation

public class TimeSeriesWindow : TermWindow {
    public enum TimeSeriesStyle {
        case block
        case line
        case dot
    }
    
    var totalTime : TimeInterval
    var timeTick : TimeInterval
    var timeCount : Int { Int(ceil(totalTime/timeTick)) }
    
    var seriesColor : TermColor = .red
    var seriesStyle : TimeSeriesStyle = .block
    var values : [Double]
    var sourceBlock : ()->Double
    
    init(tick: TimeInterval, total: TimeInterval, source: @escaping ()->Double) {
        totalTime = total
        timeTick = tick
        sourceBlock = source
        values = [Double](repeating: 0, count: Int(ceil(totalTime/timeTick)))
        super.init()
    }
}
