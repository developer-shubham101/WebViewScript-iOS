//
//  ViewController.swift
//  WebViewScript
//
//  Created by Shubham Sharma on 28/06/20.
//  Copyright © 2020 Newdevpoint. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    private var webViewContentIsLoaded = false
    
    var webUrl: String = "https://github.com/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.configuration.userContentController.add(self, name: "paymentResponse")
        
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        
        if !webViewContentIsLoaded {
            let url = URL(string: webUrl)!
            let request = URLRequest(url: url)
            webView.load(request)
            webViewContentIsLoaded = true
        }
        
        
    }
    
    
    private func evaluateJavascript(_ javascript: String, sourceURL: String? = nil, completion: ((_ error: String?) -> Void)? = nil) {
        var javascript = javascript
        
        // Adding a sourceURL comment makes the javascript source visible when debugging the simulator via Safari in Mac OS
        if let sourceURL = sourceURL {
            javascript = "//# sourceURL=\(sourceURL).js\n" + javascript
        }
        
        webView.evaluateJavaScript(javascript) { _, error in
            completion?(error?.localizedDescription)
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // This must be valid javascript!  Critically don't forget to terminate statements with either a newline or semicolon!
        let javascript =
            "var message = {\"Status\": \"SUCCESS\", \"transactionId\": \"#PAY123133\" }\n" +
        "window.webkit.messageHandlers.paymentResponse.postMessage(message)\n"
        
        evaluateJavascript(javascript, sourceURL: nil)
    }
    
    func showAlertWithMessage(title: String, message:String ) {
        let alert = UIAlertController.init(title: title , message:message , preferredStyle:.alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel) { (action) in
            
        }
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
    
    
    
}

extension ViewController: WKScriptMessageHandler {
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        
        guard let body = message.body as? [String: Any] else {
            print("could not convert message body to dictionary: \(message.body)")
            showAlertWithMessage(title: "Payment Declined", message: "" )
            return
        }
        
        guard let status = body["Status"] as? String else {
            print("could not convert Status to string: \(body)")
            showAlertWithMessage(title: "Payment Declined", message: "" )
            return
        }
        
        switch status {
        case "FAILED":
            showAlertWithMessage(title: "Payment Declined", message: "")
            print("Transaction Failed")
            break
            
        case "SUCCESS":
            guard let transactionId = body["transactionId"] as? String else {
                print("could not transactionId to string: \(body)")
                return
            }
            print("outerHTML is \(transactionId)")
            showAlertWithMessage(title: "Payment Declined", message: "Transaction Id \(transactionId)" )
            break
        default:
            print("unknown message type \(status)")
            return
        }
    }
}


