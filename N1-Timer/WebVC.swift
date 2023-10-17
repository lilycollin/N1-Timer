import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var urlString = ""
    
    var delegate: UIViewController?
    
    var webView: WKWebView!
    var reloadButton: UIButton!
    var backButton: UIButton!
    var buttonStackView: UIStackView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.navigationController?.navigationBar.tintColor = .orange
        reloadButton = UIButton(type: .custom)
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        reloadButton.tintColor = .orange
        reloadButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)
        
        backButton = UIButton(type: .custom)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .orange
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView = UIStackView(arrangedSubviews: [reloadButton, backButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonStackView.topAnchor.constraint(equalTo: webView.bottomAnchor),
            backButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            reloadButton.topAnchor.constraint(equalTo: reloadButton.topAnchor),
            reloadButton.bottomAnchor.constraint(equalTo: reloadButton.bottomAnchor),
        ])
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func reloadPage() {
        webView.reload()
    }
}
