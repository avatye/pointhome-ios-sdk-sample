//
//  InterAdLoaderController.swift
//  SPCTestSample
//
//  Created by 임재혁 on 9/19/24.
//

import UIKit
import AvatyeAdCash

class InterAdLoaderController: UIViewController{
    
    var interAdLoader: InterstitialAdLoader! = InterstitialAdLoader(placementId: "2b6fc70a-5b7e-46c2-89ba-4ed06a88bfb0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(interAdLoader)
        
        self.interAdLoader.delegate = self
        
    }
    
    @IBAction func interBtnAction(_ sender: Any) {
        self.interAdLoader.requestAd()
    }
}

extension InterAdLoaderController: InterstitialAdDelegate{
    func onInterstitalLoaded(_ apid: String) {
        print("onInterstitialLoader \(apid)")
    }
    
    func onInterstitalOpened(_ apid: String) {
        print("onInterstitalOpened \(apid)")
    }
    
    func onInterstitalClosed(_ apid: String, isCompleted: Bool) {
        print("onInterstitalClosed \(apid)")
    }
    
    func onInterstitalFailed(_ apid: String, error: AvatyeAdCash.AdCashErrorModel) {
        print("onInterstitalFailed \(apid) \(error)")
    }
    
    func onInterstitalClicked(_ apid: String) {
        print("onInterstitalClicked \(apid)")
    }
    
    
}
