import UIKit

class CircularProgressView: UIView {
    
    private var isAnimating = false
    private var pauseTime: CFTimeInterval = 0
    
    private var circleLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: frame.size.width * 0.3, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 20.0
        circleLayer.strokeColor = UIColor(named: "Gray_")?.cgColor
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor(named: "Red_")?.cgColor
        layer.addSublayer(circleLayer)
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(duration: TimeInterval) {
        if isAnimating {
            return
        }
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        isAnimating = true
    }
    
    func pauseAnimation() {
        if isAnimating, progressLayer.speed != 0 {
            let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
            progressLayer.speed = 0
            progressLayer.timeOffset = pausedTime - pauseTime
            setNeedsDisplay()
        }
    }
    
    func continueAnimation() {
        if isAnimating, progressLayer.speed == 0 {
            let pausedTime = progressLayer.timeOffset
            progressLayer.speed = 1
            progressLayer.timeOffset = 0
            progressLayer.beginTime = 0
            let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            progressLayer.beginTime = timeSincePause
        }
    }
    
    func resetProgress() {
        if isAnimating {
            progressLayer.removeAnimation(forKey: "progressAnim")
            isAnimating = false
        }
        progressLayer.strokeEnd = 0
    }
}
