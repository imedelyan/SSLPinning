import UIKit
import WebKit

class WebViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet private weak var webview: WKWebView!
  
  private var appleURL: URL {
    guard let url = URL(string: "https://www.apple.com") else {
      fatalError("Invalid URL")
    }
    return url
  }
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    webview.navigationDelegate = self
    webview.load(URLRequest(url: appleURL))
  }
}

extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)

            if isServerTrusted {
                if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
                    let data = CFDataGetBytePtr(serverCertificateData);
                    let size = CFDataGetLength(serverCertificateData);
                    let cert1 = NSData(bytes: data, length: size)
                    let file_der = Bundle.main.path(forResource: "www.apple.com", ofType: "cer")

                    if let file = file_der {
                        if let cert2 = NSData(contentsOfFile: file) {
                            if cert1.isEqual(to: cert2 as Data) {
                                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                                return
                            }
                        }
                    }
                }
            }
        }
    }

    // Pinning failed
    completionHandler(.cancelAuthenticationChallenge, nil)
  }
}
