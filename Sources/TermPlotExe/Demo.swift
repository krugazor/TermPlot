import Foundation
import TermPlot


func fillpart1( _ buffer: inout [[TermCharacter]], _ frame: Int) {
    // text IS IT / A BIRD / ?
    let rows = buffer.count
    let columns = buffer[0].count
    buffer[rows-1][columns/2] = TermCharacter("?", color: .default, styles: [.default])
    
    buffer[rows-2][columns/2-2] = TermCharacter("A", color: .default, styles: [.default])
    buffer[rows-2][columns/2-1] = TermCharacter(" ", color: .default, styles: [.default])
    buffer[rows-2][columns/2] = TermCharacter("B", color: .default, styles: [.default])
    buffer[rows-2][columns/2+1] = TermCharacter("I", color: .default, styles: [.default])
    buffer[rows-2][columns/2+2] = TermCharacter("R", color: .default, styles: [.default])
    buffer[rows-2][columns/2+3] = TermCharacter("D", color: .default, styles: [.default])
    
    buffer[rows-3][columns/2-2] = TermCharacter("I", color: .default, styles: [.default])
    buffer[rows-3][columns/2-1] = TermCharacter("S", color: .default, styles: [.default])
    buffer[rows-3][columns/2] = TermCharacter(" ", color: .default, styles: [.default])
    buffer[rows-3][columns/2+1] = TermCharacter("I", color: .default, styles: [.default])
    buffer[rows-3][columns/2+2] = TermCharacter("T", color: .default, styles: [.default])
    
    // flying @
    let step = (columns/16)*frame
    buffer[rows/3][step] = TermCharacter("@", color: .light_red, styles: [.bold])
}

func fillpart2( _ buffer: inout [[TermCharacter]], _ frame: Int) {
    // text IS IT / A PLANE / ?
    let rows = buffer.count
    let columns = buffer[0].count
    buffer[rows-1][columns/2] = TermCharacter("?", color: .default, styles: [.default])
    
    buffer[rows-2][columns/2-3] = TermCharacter("A", color: .default, styles: [.default])
    buffer[rows-2][columns/2-2] = TermCharacter(" ", color: .default, styles: [.default])
    buffer[rows-2][columns/2-1] = TermCharacter("P", color: .default, styles: [.default])
    buffer[rows-2][columns/2] = TermCharacter("L", color: .default, styles: [.default])
    buffer[rows-2][columns/2+1] = TermCharacter("A", color: .default, styles: [.default])
    buffer[rows-2][columns/2+2] = TermCharacter("N", color: .default, styles: [.default])
    buffer[rows-2][columns/2+3] = TermCharacter("E", color: .default, styles: [.default])
    
    buffer[rows-3][columns/2-2] = TermCharacter("I", color: .default, styles: [.default])
    buffer[rows-3][columns/2-1] = TermCharacter("S", color: .default, styles: [.default])
    buffer[rows-3][columns/2] = TermCharacter(" ", color: .default, styles: [.default])
    buffer[rows-3][columns/2+1] = TermCharacter("I", color: .default, styles: [.default])
    buffer[rows-3][columns/2+2] = TermCharacter("T", color: .default, styles: [.default])
    
    // flying @
    let centerX = columns-(columns/16)*frame-1
    let centerY = rows/3
    buffer[centerY][centerX] = TermCharacter("@", color: .light_red, styles: [.swap])
    if frame > 1 && frame < 4*4-1 {
        buffer[centerY][centerX-1] = TermCharacter("<", color: .light_red, styles: [.swap])
        buffer[centerY][centerX+1] = TermCharacter(">", color: .light_red, styles: [.swap])
        buffer[centerY-1][centerX] = TermCharacter("-", color: .light_red, styles: [.swap])
        buffer[centerY+1][centerX] = TermCharacter("-", color: .light_red, styles: [.swap])
    }
}

func fillpart3( _ buffer: inout [[TermCharacter]], _ frame: Int) {
    // text NO IT'S
    // TERMPLOT <- blink + block
    let rows = buffer.count
    let columns = buffer[0].count
    
    let centerX = columns/2
    let step = rows/16*frame
    
    buffer[step][centerX-3] = TermCharacter("T", color: .light_red, styles: [.swap,.blink])
    buffer[step][centerX-2] = TermCharacter("E", color: .light_blue, styles: [.swap,.blink])
    buffer[step][centerX-1] = TermCharacter("R", color: .light_cyan, styles: [.swap,.blink])
    buffer[step][centerX] = TermCharacter("M", color: .light_green, styles: [.swap,.blink])
    buffer[step][centerX+1] = TermCharacter("P", color: .light_yellow, styles: [.swap,.blink])
    buffer[step][centerX+2] = TermCharacter("L", color: .light_white, styles: [.swap,.blink])
    buffer[step][centerX+3] = TermCharacter("O", color: .light_magenta, styles: [.swap,.blink])
    buffer[step][centerX+4] = TermCharacter("T", color: .light_red, styles: [.swap,.blink])
    
    if step > 0 {
        buffer[step-1][centerX-3] = TermCharacter("N", color: .light_white, styles: [.italic])
        buffer[step-1][centerX-2] = TermCharacter("O", color: .light_white, styles: [.italic])
        buffer[step-1][centerX-1] = TermCharacter(" ", color: .light_white, styles: [.italic])
        buffer[step-1][centerX] = TermCharacter("I", color: .light_white, styles: [.italic])
        buffer[step-1][centerX+1] = TermCharacter("T", color: .light_white, styles: [.italic])
        buffer[step-1][centerX+2] = TermCharacter("'", color: .light_white, styles: [.italic])
        buffer[step-1][centerX+3] = TermCharacter("S", color: .light_white, styles: [.italic])
    }
    if step >= 8 {
        buffer[step+1][centerX-13] = TermCharacter("A", color: .light_white, styles: [.bold])
        buffer[step+1][centerX-12] = TermCharacter(" ", color: .light_white, styles: [.bold])
        buffer[step+1][centerX-11] = TermCharacter("1", color: .light_white, styles: [.bold,.swap])
        buffer[step+1][centerX-10] = TermCharacter("0", color: .light_white, styles: [.bold,.swap])
        buffer[step+1][centerX-9] = TermCharacter("0", color: .light_white, styles: [.bold,.swap])
        buffer[step+1][centerX-8] = TermCharacter(" ", color: .light_white, styles: [.bold,.swap])
        buffer[step+1][centerX-7] = TermCharacter("%", color: .light_white, styles: [.bold,.swap])
        buffer[step+1][centerX-6] = TermCharacter(" ", color: .light_white, styles: [.default])
        buffer[step+1][centerX-5] = TermCharacter("S", color: .light_yellow, styles: [.bold])
        buffer[step+1][centerX-4] = TermCharacter("W", color: .light_yellow, styles: [.bold])
        buffer[step+1][centerX-3] = TermCharacter("I", color: .light_yellow, styles: [.bold])
        buffer[step+1][centerX-2] = TermCharacter("F", color: .light_yellow, styles: [.bold])
        buffer[step+1][centerX-1] = TermCharacter("T", color: .light_yellow, styles: [.bold])
        buffer[step+1][centerX] = TermCharacter(" ", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+1] = TermCharacter("A", color: .light_red, styles: [.bold])
        buffer[step+1][centerX+2] = TermCharacter("N", color: .light_red, styles: [.bold])
        buffer[step+1][centerX+3] = TermCharacter("S", color: .light_red, styles: [.bold])
        buffer[step+1][centerX+4] = TermCharacter("I", color: .light_red, styles: [.bold])
        buffer[step+1][centerX+5] = TermCharacter(" ", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+6] = TermCharacter("L", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+7] = TermCharacter("I", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+8] = TermCharacter("B", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+9] = TermCharacter("R", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+10] = TermCharacter("A", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+11] = TermCharacter("R", color: .light_white, styles: [.bold])
        buffer[step+1][centerX+12] = TermCharacter("Y", color: .light_white, styles: [.bold])
    }
}

func doDemo() {
    TermWindow.default.clearScreen()
    
    var ctime = 0
    var timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
        ctime += 1
        if ctime <= 12 * 4 {
            TermWindow.default.requestStyledBuffer { (buffer) in
                if ctime < 4*4 { // 4s
                    fillpart1(&buffer, ctime)
                } else if ctime < 8*4 { // 4s more
                    fillpart2(&buffer, ctime - (4*4))
                } else {
                    fillpart3(&buffer, ctime - (8*4))
                }
            }
        }
    }
    
    RunLoop.current.run(until: Date.distantFuture)
}

func doSeriesDemo() {
    var v = 1
    let series = TimeSeriesWindow(tick: 0.25, total: 8) {
        v += 1
        v = v % 10
        let random = Int.random(in: 0...v)
        return Double(random)
    }
    series.seriesColor = .monochrome(.light_cyan)

    let switchTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
        let next : TimeSeriesWindow.TimeSeriesStyle
        switch series.seriesStyle {
        case .block:
            next = .line
            series.seriesColor = .monochrome(.light_red)
        case .line:
            next = .dot
            series.seriesColor = .monochrome(.light_yellow)
       case .dot:
            next = .block
            series.seriesColor = .monochrome(.light_cyan)
        }
        series.seriesStyle = next
    }
    
    series.start()
    RunLoop.current.run(until: Date.distantFuture)
}
