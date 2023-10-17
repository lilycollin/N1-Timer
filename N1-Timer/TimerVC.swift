import UIKit
import AVFoundation

class TimerVC: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var player: AVAudioPlayer?

    func playSound() {
        if timerState != .complete {
            guard let path = Bundle.main.path(forResource: "getReady", ofType:"wav") else {
                return }
            let url = URL(fileURLWithPath: path)
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func playSoundEnd() {
        guard let path = Bundle.main.path(forResource: "end", ofType:"mp3") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSoundStart() {
        guard let path = Bundle.main.path(forResource: "start", ofType:"mp3") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var roundLabel: UILabel!
    
    var stateLabel: UILabel!
    
    enum TimerState: String {
        case ready = "READY"
        case active = "ACTIVE"
        case pause = "PAUSE"
        case `break` = "BREAK"
        case complete = "END"
    }
    
    var isBreak = false
    
    var timerState: TimerState = .ready
    
    var timer: Timer!
    
    var currentTime: Double!
    var currentRound: Int!
    
    var titleView: UIView!
    var titleLabel: UILabel!
    
    var startButton: UIButton!
    var startView: UIView!
    
    var circularView: CircularProgressView!
    var duration: TimeInterval!
    
    var rounds: Int!
    var roundTime: Int!
    var breakTime: Int!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        currentTime = Double(roundTime)
        currentRound = 1
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "DarkGray_")
        activateProximitySensor(isOn: true)
        setupTimerView()
        setupTitleView()
        setupLabels()
        setupStartView()
        if UserDefaults.standard.object(forKey: "helper") == nil {
            let hintView = HintView()
            hintView.delegate = self
            self.view.addSubview(hintView)
            UserDefaults.standard.setValue(true, forKey: "helper")
        } else {
            runRound()
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    func activateProximitySensor(isOn: Bool) {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = isOn
        if isOn {
            NotificationCenter.default.addObserver(self, selector: #selector(proximityStateDidChange), name: UIDevice.proximityStateDidChangeNotification, object: device)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: device)
        }
    }
    
    var proximity = true
    
    @objc func proximityStateDidChange(notification: NSNotification) {
            if proximity {
                tap()
                proximity = false
            } else {
                proximity = true
            }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        activateProximitySensor(isOn: false)
    }
    
    @objc func tap() {
        if timerState == .active || timerState == .break {
            if timerState == .active {
                isBreak = false
            } else {
                isBreak = true
            }
            timerState = .pause
            pauseTimer()
        } else if timerState == .pause {
            if isBreak {
                timerState = .break
            } else {
                timerState = .active
            }
            continueTimer()
        }
        updateStatusLabel()
    }
    
    //MARK: - setupLabels
    func setupLabels() {
        roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        let text = "Round : \(currentRound ?? 1)"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 25) ?? .systemFont(ofSize: 25)], range: NSRange(location: 0, length: text.count))
        roundLabel.attributedText = attributedText
        view.addSubview(roundLabel)
        NSLayoutConstraint.activate([
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20)
        ])
        
        stateLabel = UILabel()
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        updateStatusLabel()
        view.addSubview(stateLabel)
        NSLayoutConstraint.activate([
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: - setupTimerView
    func setupTimerView(){
        circularView = CircularProgressView(frame: view.frame)
        view.addSubview(circularView)
        circularView.center = view.center
    }
    
    //MARK: - setipTitleView
    func setupTitleView() {
        titleView = UIView()
        titleView.backgroundColor = UIColor(named: "Gray_")
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.clipsToBounds = true
        titleView.layer.cornerRadius = 10
        view.addSubview(titleView)
        titleLabel = UILabel()
        titleView.addSubview(titleLabel)
        let text = "N1TIMER"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "Red_") ?? .red, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 30) ?? .systemFont(ofSize: 30)], range: NSRange(location: 0, length: 2))
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 30) ?? .systemFont(ofSize: 30)], range: NSRange(location: 2, length: text.count-2))
        titleLabel.attributedText = attributedText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleView.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: -20),
            titleView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.2),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -10)
        ])
    }
    
    //MARK: - setupStartView
    func setupStartView() {
        startView = UIView()
        startView.translatesAutoresizingMaskIntoConstraints = false
        startView.clipsToBounds = true
        startView.layer.cornerRadius = 10
        view.addSubview(startView)
        startView.layer.borderColor = UIColor(named: "Red_")?.cgColor
        startView.layer.borderWidth = 2
        startView.isUserInteractionEnabled = true
        
        startView.backgroundColor = UIColor(named: "Gray_")
        
        startButton = UIButton(type: .custom)
        startButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        startButton.isUserInteractionEnabled = true
        let text = "Back"
        var attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 15) ?? .systemFont(ofSize: 15)], range: NSRange(location: 0, length: text.count))
        startButton.setAttributedTitle(attributedText, for: .normal)
        attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "Red_") ?? .red, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 15) ?? .systemFont(ofSize: 15)], range: NSRange(location: 0, length: text.count))
        startButton.setAttributedTitle(attributedText, for: .highlighted)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startView.addSubview(startButton)
        NSLayoutConstraint.activate([
            startView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            startView.heightAnchor.constraint(equalTo: startView.widthAnchor, multiplier: 0.5),
            
            startButton.centerXAnchor.constraint(equalTo: startView.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: startView.centerYAnchor),
            startButton.heightAnchor.constraint(equalTo: startView.heightAnchor),
            startButton.widthAnchor.constraint(equalTo: startView.widthAnchor)
        ])
    }
    
    //MARK: - back
    @objc func back() {
        timerState = .complete
        activateProximitySensor(isOn: false)
        self.dismiss(animated: true)
    }
    
    //MARK: - step
    @objc func step(){
        currentTime -= 0.1
        if currentTime <= 0 {
            timer.invalidate()
            if currentRound < rounds {
                self.currentRound += 1
                self.updateRoundLabel()
                if TimerManager.shared.withBreak {
                    runBreak()
                } else {
                    self.currentTime = Double(self.roundTime)
                    runRound()
                }
            } else {
                timerEnd()
            }
        }
    }
    
    func timerEnd() {
        playSoundEnd()
        timerState = .complete
        updateStatusLabel()
        Vibration.error.vibrate()
        activateProximitySensor(isOn: false)
    }
    
    //MARK: - step
    @objc func stepBreak(){
        currentTime -= 0.1
        if currentTime <= 0 {
            timer.invalidate()
            runRound()
        }
    }
    
    func runBreak() {
        self.playSoundStart()
        timerState = .break
        updateStatusLabel()
        currentTime = Double(breakTime)
        self.duration = TimeInterval(self.breakTime)
        self.circularView.resetProgress()
        self.circularView.progressAnimation(duration: self.duration)
        self.circularView.progressLayer.strokeColor = UIColor(.white).cgColor
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.stepBreak), userInfo: nil, repeats: true)
        print("Break run")
    }
    
    func runRound() {
        runPrepare {
            self.timerState = .active
            self.updateStatusLabel()
            self.currentTime = Double(self.roundTime)
            self.duration = TimeInterval(self.roundTime)
            self.circularView.progressAnimation(duration: self.duration)
            self.circularView.progressLayer.strokeColor = UIColor(named: "Red_")?.cgColor
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.step), userInfo: nil, repeats: true)
            print("Round run")
        }
    }
    
    func runPrepare(completion: @escaping () -> ()) {
        timerState = .ready
        updateStatusLabel()
        duration = TimeInterval(5)
        circularView.resetProgress()
        circularView.progressLayer.strokeColor = UIColor(.yellow).cgColor
        circularView.progressAnimation(duration: duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.playSound()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.circularView.resetProgress()
            print("Complete")
            completion()
        })
    }
    
    //MARK: - updateRoundLabel
    func updateRoundLabel() {
        let text = "Round : \(currentRound ?? 1)"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 25) ?? .systemFont(ofSize: 25)], range: NSRange(location: 0, length: text.count))
        roundLabel.attributedText = attributedText
    }
    
    func pauseTimer() {
        circularView.pauseAnimation()
        timer.invalidate()
    }
    
    func continueTimer() {
        circularView.continueAnimation()
        timer.invalidate()
        switch timerState {
        case .active:
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.step), userInfo: nil, repeats: true)
            break
        case .break:
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.stepBreak), userInfo: nil, repeats: true)
            break
        default: break
        }
    }
    
    func updateStatusLabel() {
        let attributedText = NSMutableAttributedString(string: timerState.rawValue)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: timerState.rawValue.count))
        stateLabel.attributedText = attributedText
    }
}
