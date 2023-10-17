import Foundation

class TimerManager {
    
    static var shared = TimerManager(withBreak: false, rounds: 1, roundTime: 15, breakTime: nil)
    
    var withBreak: Bool
    var rounds: Int
    var roundTime: Int
    var breakTime: Int?
    
    init(withBreak: Bool, rounds: Int, roundTime: Int, breakTime: Int?) {
        self.withBreak = withBreak
        self.rounds = rounds
        self.roundTime = roundTime
        self.breakTime = breakTime
    }
    
}
