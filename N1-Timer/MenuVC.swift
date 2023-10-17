import UIKit

class MenuVC: UIViewController {
    
    var rounds: Int = 1 {
        didSet {
            if rounds <= 1 {
                breakSwitch.setOn(false, animated: true)
                breakSwitched()
                UIView.animate(withDuration: 0.3, animations: {
                    self.breakSwitch.isEnabled = false
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.breakSwitch.isEnabled = true
                })
            }
        }
    }
    var timePerRound: Int = 60
    var timeBreak: Int = 15
    
    var squareViews: [UIView] = []
    var roundsLabel: UILabel!
    
    var roundsTimeLabel: UILabel!
    var timeStepper: UIStepper!
    
    var titleView: UIView!
    var titleLabel: UILabel!
    
    var breakView: UIView!
    var breakSwitchView: UIView!
    var breakSwitch: UISwitch!
    
    var startButton: UIButton!
    var startView: UIView!
    
    var breakTimeLabel: UILabel!
    var breakTimeStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "DarkGray_")
        setupTitleView()
        setupBreakView()
        setupSettingsView()
        setupStartView()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
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
        self.titleView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height * 0.2)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5) {
            self.titleView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func setupSettingsView() {
        roundsLabel = UILabel()
        var text = "Rounds: \(rounds)"
        var attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
        roundsLabel.attributedText = attributedText
        roundsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundsLabel)
        NSLayoutConstraint.activate([
            roundsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            roundsLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 30)
        ])
        
        let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 10
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false

                for i in 0..<10 {
                    let squareView = UIView()
                    squareView.clipsToBounds = true
                    squareView.layer.cornerRadius = 10
                    squareView.tag = i
                    squareView.backgroundColor = (i < rounds) ? UIColor(named: "Red_") : UIColor(named: "Gray_")
                    squareView.translatesAutoresizingMaskIntoConstraints = false
                    stackView.addArrangedSubview(squareView)
                    squareViews.append(squareView)

                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(squareViewTapped(_:)))
                    squareView.addGestureRecognizer(tapGesture)
                    squareView.isUserInteractionEnabled = true
                }

                view.addSubview(stackView)

                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    stackView.topAnchor.constraint(equalTo: roundsLabel.bottomAnchor, constant: 16),
                    stackView.heightAnchor.constraint(equalToConstant: 50),
                    stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95)
                ])
        
        roundsTimeLabel = UILabel()
        roundsTimeLabel.numberOfLines = 0
        text = "Time per Round: \(timeToString(timePerRound))"
        attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
        roundsTimeLabel.attributedText = attributedText
        roundsTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundsTimeLabel)
        NSLayoutConstraint.activate([
            roundsTimeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            roundsTimeLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30)
        ])
        
        timeStepper = UIStepper()
        timeStepper.translatesAutoresizingMaskIntoConstraints = false
        timeStepper.maximumValue = 900
        timeStepper.minimumValue = 15
        timeStepper.stepValue = 15
        timeStepper.value = 60
        if #available(iOS 13.0, *) {
            timeStepper.clipsToBounds = true
            timeStepper.layer.cornerRadius = 10
            timeStepper.layer.borderColor = UIColor(named: "Red_")?.cgColor
            timeStepper.layer.borderWidth = 2
            timeStepper.backgroundColor = UIColor(named: "Gray_")
            timeStepper.tintColor =  .white
            timeStepper.setDecrementImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            timeStepper.setIncrementImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        }
        timeStepper.addTarget(self, action: #selector(timerChanged), for: .valueChanged)
        view.addSubview(timeStepper)
        
        NSLayoutConstraint.activate([
            timeStepper.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            timeStepper.leftAnchor.constraint(greaterThanOrEqualTo: roundsTimeLabel.rightAnchor, constant: 8),
            timeStepper.centerYAnchor.constraint(equalTo: roundsTimeLabel.centerYAnchor)
        ])
        
    }
    
    @objc func timerChanged() {
        Vibration.selection.vibrate()
        timePerRound = Int(timeStepper.value)
        let text = "Time per Round: \(timeToString(timePerRound))"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
        roundsTimeLabel.attributedText = attributedText
    }
    
    @objc func squareViewTapped(_ sender: UITapGestureRecognizer) {
            if let selectedView = sender.view {
                rounds = selectedView.tag + 1
                let text = "Rounds: \(rounds)"
                let attributedText = NSMutableAttributedString(string: text)
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
                UIView.animate(withDuration: 0.3) {
                    self.roundsLabel.attributedText = attributedText
                    for i in self.squareViews {
                        i.backgroundColor = (i.tag < self.rounds) ? UIColor(named: "Red_") : UIColor(named: "Gray_")
                    }
                }
                Vibration.selection.vibrate()
            }
        }
    
    func setupBreakView() {
        breakView = UIView()
        breakView.backgroundColor = UIColor(named: "Gray_")
        breakView.translatesAutoresizingMaskIntoConstraints = false
        breakView.clipsToBounds = true
        breakView.layer.cornerRadius = 10
        view.addSubview(breakView)
        
        breakSwitchView = UIView()
        breakSwitchView.backgroundColor = UIColor(named: "Gray_")
        breakSwitchView.translatesAutoresizingMaskIntoConstraints = false
        breakSwitchView.clipsToBounds = true
        breakSwitchView.layer.cornerRadius = 10
        breakView.addSubview(breakSwitchView)
        
        breakSwitch = UISwitch()
        breakSwitch.addTarget(self, action: #selector(breakSwitched), for: .valueChanged)
        breakSwitch.isOn = false
        breakSwitch.isEnabled = false
        breakSwitch.clipsToBounds = true
        breakSwitch.layer.cornerRadius = breakSwitch.frame.height/2
        breakSwitch.onTintColor = UIColor(named: "Gray_")
        breakSwitch.translatesAutoresizingMaskIntoConstraints = false
        breakSwitch.thumbTintColor = .white
        breakSwitchView.addSubview(breakSwitch)
        
        let breakTitle = UILabel()
        breakSwitchView.addSubview(breakTitle)
        var text = "Break"
        var attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 30) ?? .systemFont(ofSize: 30)], range: NSRange(location: 0, length: text.count))
        breakTitle.attributedText = attributedText
        breakTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            breakView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            breakView.widthAnchor.constraint(equalTo: view.widthAnchor),
            breakView.heightAnchor.constraint(equalToConstant: view.frame.height*0.6),
            breakView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height*0.35),
            
            breakSwitchView.centerXAnchor.constraint(equalTo: breakView.centerXAnchor),
            breakSwitchView.widthAnchor.constraint(equalTo: breakView.widthAnchor),
            breakSwitchView.heightAnchor.constraint(equalToConstant: 80),
            breakSwitchView.topAnchor.constraint(equalTo: breakView.topAnchor),
            
            breakTitle.centerYAnchor.constraint(equalTo: breakSwitchView.centerYAnchor),
            breakTitle.leftAnchor.constraint(equalTo: breakSwitchView.leftAnchor, constant: 20),
            
            breakSwitch.centerYAnchor.constraint(equalTo: breakSwitchView.centerYAnchor),
            breakSwitch.rightAnchor.constraint(equalTo: breakSwitchView.rightAnchor, constant: -20),
        ])
        self.breakView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height*0.3)
        UIView.animate(withDuration: 0.5) {
            self.breakView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        breakTimeLabel = UILabel()
        breakTimeLabel.numberOfLines = 0
        text = "Break time: \(timeToString(timeBreak))"
        attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
        breakTimeLabel.attributedText = attributedText
        breakTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        breakView.addSubview(breakTimeLabel)
        NSLayoutConstraint.activate([
            breakTimeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            breakTimeLabel.topAnchor.constraint(equalTo: breakSwitchView.bottomAnchor, constant: 20)
        ])
        
        breakTimeStepper = UIStepper()
        breakTimeStepper.translatesAutoresizingMaskIntoConstraints = false
        breakTimeStepper.maximumValue = 300
        breakTimeStepper.minimumValue = 15
        breakTimeStepper.stepValue = 15
        breakTimeStepper.value = 15
        if #available(iOS 13.0, *) {
            breakTimeStepper.clipsToBounds = true
            breakTimeStepper.layer.cornerRadius = 10
            breakTimeStepper.layer.borderColor = UIColor(named: "Red_")?.cgColor
            breakTimeStepper.layer.borderWidth = 2
            breakTimeStepper.backgroundColor = UIColor(named: "Gray_")
            breakTimeStepper.tintColor = .white
            breakTimeStepper.setDecrementImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            breakTimeStepper.setIncrementImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        }
        breakTimeStepper.addTarget(self, action: #selector(breakTimerChanged), for: .valueChanged)
        breakView.addSubview(breakTimeStepper)
        
        NSLayoutConstraint.activate([
            breakTimeStepper.rightAnchor.constraint(equalTo: breakView.rightAnchor, constant: -20),
            breakTimeStepper.centerYAnchor.constraint(equalTo: breakTimeLabel.centerYAnchor)
        ])
        breakTimeStepper.alpha = 0
        breakTimeStepper.isEnabled = false
        breakTimeLabel.alpha = 0
    }
    
    @objc func breakTimerChanged() {
        Vibration.selection.vibrate()
        timeBreak = Int(breakTimeStepper.value)
        let text = "Break time: \(timeToString(timeBreak))"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(.white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20) ?? .systemFont(ofSize: 20)], range: NSRange(location: 0, length: text.count))
        breakTimeLabel.attributedText = attributedText
    }
    
    @objc func breakSwitched() {
        UIView.animate(withDuration: 0.5) {
            if self.breakSwitch.isOn {
                TimerManager.shared.withBreak = true
                self.breakTimeStepper.alpha = 1
                self.breakTimeStepper.isEnabled = true
                self.breakTimeLabel.alpha = 1
                self.breakSwitchView.backgroundColor = UIColor(named: "Red_")
                self.breakView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height*0.2)
            } else {
                TimerManager.shared.withBreak = false
                self.breakTimeStepper.alpha = 0
                self.breakTimeStepper.isEnabled = false
                self.breakTimeLabel.alpha = 0
                self.breakSwitchView.backgroundColor = UIColor(named: "Gray_")
                self.breakView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
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
        startButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        startButton.isUserInteractionEnabled = true
        let text = "Start"
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
    
    @objc func startTimer() {
        let vc = TimerVC()
        vc.breakTime = timeBreak
        vc.rounds = rounds
        vc.roundTime = timePerRound
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
}

func timeToString(_ timeInt : Int) -> String {
    var time: String {
        let minutes: Int = timeInt / 60
        var res = ""
        if minutes < 10 {
            res = "0\(minutes):"
        } else {
            res = "\(minutes):"
        }
        if timeInt - minutes*60 < 10 {
            res += "0\(timeInt - minutes*60)"
        } else {
            res += "\(timeInt - minutes*60)"
        }
        return res
    }
    return time
}
