//
//  CashButtonWebViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 8/27/24.
//

import UIKit
import AvatyePointHome

class CashButtonWebViewController: UIViewController{
    
    var originalUserAgent: String = ""
    
    var pointHomeService: AvatyePHService! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pointHomeService = AvatyePHService(rootViewController: self, appId: "a16dfc23feeb4e379957a9d0cdc8d81f", appSecretKey: "c52e8e00b2954895", userKey: "123")
        
        self.pointHomeService.delegate = self
        
    }
    
    @IBAction func buttonClickAction(_ sender: Any) {
        
        self.pointHomeService.openPointHome { result in
            switch result {
            case .success(let result):
                print("result \(result)")
            case .failure(let err):
                print("error \(err)")
            }
        }
    }
    
}

extension CashButtonWebViewController: AvatyePHDelegate {
    func pointHomeEventListener(event: String) {
        print("pointHomeEventListener")
    }
    
    func pointHomeSystemEventListener(event: String) {
        print("pointHomeSystemEventListener")
    }
    
    func pointHomeSliderOpened(caller: String) {
        print("pointHomeSliderOpened")
    }
    
    func pointHomeSliderClosed(caller: String) {
        print("pointHomeSliderClosed")
    }
    
    
}


