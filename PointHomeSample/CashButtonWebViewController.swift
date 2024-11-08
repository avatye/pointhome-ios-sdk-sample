//
//  CashButtonWebViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 8/27/24.
//

import UIKit
import WebKit
import AvatyePointHome


class CashButtonWebViewController: UIViewController{
    
//    var webView: CBPointHomeWebView! = nil
//    
//    var pointHomeService: AvatyePHService! = nil
//    
//    let appId: String = "16a99b26a7f64be4b512f4e82d972a5a"
//    let appSecretKey: String = "a27984cf4bca4194"
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        webView = CBPointHomeWebView(frame: .zero, rootViewController: self, appId: "16a99b26a7f64be4b512f4e82d972a5a", appSecretKey: "a27984cf4bca4194", userKey: "123")
//
//        self.view.addSubview(self.webView)
//        
//        self.webView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
//            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.webView.heightAnchor.constraint(equalToConstant: 250),
//        ])
//        
////        webView.userDataChanged(token: "123") { result in
////            switch result {
////            case .success:
////                print("userDataChanged success")
////            case .failure:
////                print("userDataChanged failure")
////            }
////        }
//        self.webView.delegate = self
//        
//        webView.startWebView(widgetID: "gt3AjoNiMVxhqFTQ", actionID: "")
//        
//        pointHomeService = AvatyePHService(rootViewController: self, appId: appId, appSecretKey: appSecretKey, userKey: "123")
//        pointHomeService.delegate = self
//    
//    }
//    
//    @IBAction func dashBtnAction(_ sender: Any) {
//        pointHomeService.openPointHome { result in
//            switch result {
//            case .success(let t):
//                PointHomeLogger.debug("pointHomeService open PointHome ")
//            case .failure(let err):
//                PointHomeLogger.debug("pointHomeService open Error \(err)")
//            }
//        }
//    }
    
}

//extension CashButtonWebViewController: PHWebViewDelegate{
//    func webEventListener(event: String) {
//        print("webEventListener \(event)")
//    }
//    
//    func webSystemEventListener(event: String) {
//        print("webSystemEventListener \(event)")
//    }
//    
//    func pointHomeOpenDelegate(caller: String) {
//        print("pointHomeOpenDelegate \(caller)")
//    }
//    
//    func PointHomeCloseDelegate(caller: String) {
//        print("PointHomeCloseDelegate \(caller)")
//    }
//}
//
//extension CashButtonWebViewController: AvatyePHDelegate{
//    func pointHomeEventListener(event: String) {
//        print("pointHomeEventListener \(event)")
//    }
//    
//    func pointHomeSystemEventListener(event: String) {
//        print("pointHomeSystemEventListener \(event)")
//    }
//    
//    func pointHomeSliderOpened(caller: String) {
//        print("pointHomeSliderOpened \(caller)")
//    }
//    
//    func pointHomeSliderClosed(caller: String) {
//        print("pointHomeSliderClosed \(caller)")
//        webView.startWebView(widgetID: "gt3AjoNiMVxhqFTQ", actionID: "")
//    }
//}
