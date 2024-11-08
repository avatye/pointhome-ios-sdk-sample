//
//  webSDKTestViewController.swift
//  SPCTestSample
//
//  Created by 임재혁 on 2/23/24.
//

import UIKit
import PointHome
import WebKit
import AppTrackingTransparency
import AdSupport

class webSDKTestViewController: UIViewController {
    
    var webView: WKWebView = WKWebView()
    
    @IBOutlet weak var openBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scriptMessageHandler = AvatyeWebSDKController(rootWebView: webView)
        webView.configuration.userContentController.add(scriptMessageHandler, name: "AvatyeBridge_SPC")
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.openBtn.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        if let url = URL(string: "https://avatye-resources.s3.ap-northeast-2.amazonaws.com/pointhome/test/index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        
//        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
//            (records) -> Void in
//            for record in records {
//                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
//                // remove callback
//             }
//         })
        
    }
    
    @IBAction func openBtnAction(_ sender: Any) {
        PointHome.openService(rootVC: self, userKey: "123123") { result in
            switch result {
            case .success(let t):
                print("t \(t)")
            case .failure(let e):
                print("error \(e)")
            }
        }
    }
}

extension webSDKTestViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("웹 페이지 로드 완료")
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          guard let url = navigationAction.request.url else {
              print("webVIew decidePolicy")
              decisionHandler(.cancel)
              return
          }
        
          if url.absoluteString != "https://avatye-resources.s3.ap-northeast-2.amazonaws.com/pointhome/test/index.html" {
              // 웹뷰에서 사용중인 url과 다를 경우, 기본 브라우저로 오픈 처리
              UIApplication.shared.open(url, options: [:]) { isSuccess in
                  // after open
              }
              decisionHandler(.cancel)
          } else {
              // 웹뷰 내에서 랜딩
              decisionHandler(.allow)
          }
    }
    
}

extension webSDKTestViewController: WKUIDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("window.open 호출")
        print("ui delegate open \(navigationAction.request.url?.absoluteString)")
        
        if let urlString = navigationAction.request.url?.absoluteString,
           let url = URL(string: urlString){
            UIApplication.shared.open(url, options: [:]){ status in
                print("url open \(urlString)")
            }
        }
        
        return nil
    }
}

