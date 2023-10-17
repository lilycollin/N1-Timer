import UIKit

class HintView: UIView {
    
    var delegate: TimerVC!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let centerView = UIView()
        centerView.backgroundColor = UIColor(named: "Gray_")
        centerView.layer.cornerRadius = 10
        centerView.clipsToBounds = true
        
        let label = UILabel()
        let text = "Move your hand near the screen to turn pause on/off"
        var attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(ciColor: .white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 12) ?? .systemFont(ofSize: 12)], range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let imageView = UIImageView(image: UIImage(systemName: "info.circle"))
        imageView.tintColor = UIColor(named: "Red_")
        imageView.contentMode = .scaleAspectFill
        
        let closeButton = UIButton(type: .custom)
        attributedText = NSMutableAttributedString(string: "OKAY")
        attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(ciColor: .white), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 16) ?? .systemFont(ofSize: 12)], range: NSRange(location: 0, length: "OKAY".count))
        closeButton.setAttributedTitle(attributedText, for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 10
        closeButton.layer.borderWidth = 2
        closeButton.layer.borderColor = UIColor(named: "Red_")?.cgColor
        closeButton.addTarget(self, action: #selector(closeHint), for: .touchUpInside)
        
        centerView.addSubview(label)
        centerView.addSubview(imageView)
        centerView.addSubview(closeButton)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(centerView)
        
        NSLayoutConstraint.activate([
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView.widthAnchor.constraint(equalToConstant: 300), // Подберите размеры под ваши требования
            centerView.heightAnchor.constraint(equalToConstant: 200),
            
            imageView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            label.widthAnchor.constraint(equalToConstant: 250),
            label.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            
            closeButton.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    @objc func closeHint() {
        removeFromSuperview()
        delegate.runRound()
    }
}
