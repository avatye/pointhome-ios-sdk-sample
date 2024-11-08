//
//  ViewController.swift
//  SPCTestSample
//
//  Created by 임재혁 on 2024/02/21.
//

import UIKit
import AdSupport
import PointHome
import AvatyeAdCash

class ViewController: UIViewController {
    
    @IBOutlet weak var appIdLabel: UILabel!
    
    let uuid: String = UIDevice.current.identifierForVendor!.uuidString
    let IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString

    @IBOutlet weak var bannerView: UIView!
    
//    var namBanner: PointHomeAdLoader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        namBanner = PointHomeAdLoader(rootVC: self,
//                                       placementId: "d6da84a3-d614-4df3-bc7a-866a1f1fa1ad",
//                                        width: 380)
//        namBanner.delegate = self
        
        self.appIdLabel.text = "appId:\naf46ad7d30ea40f88ddf0d76345d89f9"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Life-Cycle vieWillAppear")
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Life-Cycle viewDidAppear")
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Life-Cycle viewWillDisappear")
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Life-Cycle viewDidDisappear")
        super.viewDidDisappear(animated)
    }
    
    @IBAction func openBtnAction(_ sender: Any) {
        PointHome.openService(rootVC: self, userKey: "12313") { result in
            switch result {
            case .success(let t):
                print("t \(t)")
            case .failure(let e):
                print("error \(e)")
            }
        }
    }
    
    @IBAction func getFeedAction(_ sender: Any) {
        let feedModel: PHFeedParamModel = PHFeedParamModel(IDFA: IDFA, placementID: "76677041-72b0-4307-8311-ad3ae008d4e0")
        
        PointHome.getFeed(userKey: uuid, param: feedModel) { result in
            switch result {
            case .success(let t):
                print("pointHome getFeed success \(t.items.count)")
                DispatchQueue.main.async {
                    let label = UILabel()
                    if let itemText = t.items[0].name as? String{
                        label.text = "PointHome GetFeed Success : " + itemText
                        self.bannerView.addSubview(label)
                        label.translatesAutoresizingMaskIntoConstraints = false
                        
                        NSLayoutConstraint.activate([
                            label.bottomAnchor.constraint(equalTo: self.bannerView.bottomAnchor, constant: -20),
                            label.leadingAnchor.constraint(equalTo: self.bannerView.leadingAnchor, constant: 20)
                        ])
                    }
                }
            case .failure(let e):
                print("pointHome getFeed fail \(e)")
            }
        }
    }
    
    @IBAction func namBannerAction(_ sender: Any) {
//        namBanner.requestAd()
    }

}

extension ViewController: PHAdLoaderDelegate{
    func onBannerLoaded(_ apid: String, adView: UIView, size: CGSize) {
        print("onBannerLoaded")
        self.bannerView.addSubview(adView)
    }
    
    func onBannerFailed(_ apid: String, error: PointHomeError) {
        print("onBannerFailed\(error)")
    }
    
    func onBannerClicked(_ apid: String) {
        print("onBannerClicked")
    }
    
    func onBannerRemoved(_ apid: String) {
        print("onBannerRemoved")
    }
    
    
}

extension ViewController: BannerAdWidgetDelegate{
    func onBannerLoaded(_ apid: String) {
        print("onBannerLoaded")
    }
    
    func onBannerFailed(_ apid: String, error: AvatyeAdCash.AdCashErrorModel) {
        print("onBannerFailed \(apid) error : \(error)")
    }
    
    
}
