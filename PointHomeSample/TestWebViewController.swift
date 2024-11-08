//
//  TestWebViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 2024/01/04.
//

import UIKit
import WebKit
import AvatyePointHome

class TestWebViewController: UIViewController{

    var webView: WKWebView! = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scriptMessageHandler = AvatyeWebSDKController(rootWebView: webView)
        webView.configuration.userContentController.add(scriptMessageHandler, name: "PointHome_WebSDK")
        
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        if let url = URL(string: "https://avatye-resources.s3.ap-northeast-2.amazonaws.com/pointhome/test/sspTest/index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
            print("testWebViewController viewDidLoad")
        }
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
    }
    
}

extension TestWebViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로드 완료")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("naviagationAction \(navigationAction.request.url?.absoluteString)")
        
        
        if let urlString = navigationAction.request.url?.absoluteString,
           let url = URL(string: urlString){
            if urlString != "https://avatye-resources.s3.ap-northeast-2.amazonaws.com/pointhome/test/sspTest/index.html"{
                UIApplication.shared.open(url, options: [:]){ status in
                    print("url open \(urlString)")
                    print("url open status \(status)")
                }
            }
        }
        
        decisionHandler(.allow)
    }
}

extension TestWebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("12312312312132")
    }
    
    
}

    
