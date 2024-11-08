//
//  AdCashController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 4/11/24.
//

import UIKit
import AdCashFramework

class AdCashController: UIViewController{
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var appIdLabel: UILabel!
    @IBOutlet weak var appSecretKeyLabel: UILabel!
    @IBOutlet weak var ApIdLabel: UILabel!
    
    let appId: String = "6626e5f80d3b4642a5ed2638dcc20f38"
    let appSecretKey: String = "a01ff9b3d5d54068"
    let APID: String = "4598b895-a213-4e06-b6ef-602eb4f33eb2"
    let InterAPID: String = "2e1868bd-fe27-4065-af83-94ac5641683b"
    let nativeAPID: String = "f499d84a-9a2c-464a-8c1b-ffd6e4d2392d"
    
    
    var bannerLoader: BannerAdLoader! = nil
    
    var bannerAdView: BannerAdView! = nil
    
    var interLoader: InterstitialAdLoader! = nil
    
    private var nativeLoader: NativeAdLoader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appIdLabel.text = "appId: \(appId)"
        self.appSecretKeyLabel.text = "appSecretKey: \(appSecretKey)"
        self.ApIdLabel.text = "APID: \(APID)"
        
//        bannerLoader = BannerAdLoader(rootVC: self, placementId: APID, size: .DYNAMIC)
//            .setConfig(appId: appId, appSecretKey: appSecretKey)
//        bannerLoader.delegate = self
//        
//        bannerLoader.setNAMNative { adPopcornSSPNativeAd, nib in
//            
//            if let xibView = nib.instantiate(withOwner: nil, options: nil).first as? GFPNativeSimpleAdView {
//                print("xibView instantiate  success \(xibView)")
//                let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
//                apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
//                adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
//            }else{
//                print("xibView instantiate failed")
//            }
//
//        }
        
        bannerAdView = BannerAdView(frame: .zero).setConfig(appId: appId, appSecretKey: appSecretKey)
        bannerAdView.setBannerAd(rootVC: self, placementId: APID, size: .DYNAMIC)
        bannerAdView.delegate = self
        
        bannerAdView.setNAMNative { adPopcornSSPNativeAd, nib in

            if let xibView = nib.instantiate(withOwner: nil, options: nil).first as? GFPNativeSimpleAdView {
                print("xibView instantiate  success \(xibView)")
                let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
                apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
                adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
            }else{
                print("xibView instantiate failed")
            }

        }
        
        self.bannerView.addSubview(self.bannerAdView)
        
        
        interLoader = InterstitialAdLoader(placementId: InterAPID, rootViewController: self)
//            .setConfig(appId: appId, appSecretKey: appSecretKey)
        interLoader.delegate = self
    
    }
    
    @IBAction func requsetAdBtnAction(_ sender: Any) {
//        bannerLoader.requestAd()
        bannerAdView.requestAd()
    }
    
    @IBAction func testBtnAction(_ sender: Any) {
        interLoader.requestAd()
    }
    

    @IBAction func stopAdBtnAction(_ sender: Any) {
//        bannerLoader.removeAd()
    }
    
    func showAlert(message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                print("OK button tapped")
            }
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension AdCashController: BannerAdLoaderDelegate{
    func onBannerLoaded(_ apid: String, adView: UIView, size: CGSize) {
        print("adCashController adCash frame onBannerLoaded size \(size)")
        
        self.view.addSubview(adView)
        
//        adView.frame = CGRect(x: 0, y: 0, width: ewidth, height: eheight)
    
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            adView.widthAnchor.constraint(equalToConstant: size.width),
            adView.heightAnchor.constraint(equalToConstant: size.height),
            adView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            adView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        print("bannerView frame point \(self.bannerView.frame.origin.x) \(self.bannerView.frame.origin.y)")
        
        print("adView frame point \(adView.frame.origin.x) \(adView.frame.origin.y)")
        print("adView frame size \(adView.frame.width) \(adView.frame.height)")
    }
    
    func onBannerClicked(_ apid: String) {
        print("adCashController adCash onBannerClicked")
    }
    
    func onBannerRemoved(_ apid: String) {
        print("adCashController adCash onBannerRemoved")
    }
    
    func onBannerFailed(_ apid: String, error: AdCashFramework.AdCashErrorModel) {
        print("adCashController adCash onBannerFailed \(error.code)")
        print("adCashController adCash onBannerFailed \(error.desc)")
        
        self.showAlert(message: "code : \(error.code)\ndesc : \(error.desc)")
        
    }
}

extension AdCashController: InterstitialAdDelegate{
    func onInterstitalLoaded(_ apid: String) {
        print("adCashController interstitial Loaded")
        
    }
    
    func onInterstitalOpened(_ apid: String) {
        print("adCashController interstitial opened")
    }
    
    func onInterstitalClicked(_ apid: String) {
        print("adCashController interstitial clicked")
    }
    
    func onInterstitalFailed(_ apid: String, error: AdCashFramework.AdCashErrorModel) {
        print("adCashControlleradCashController interstitial failed \(error.message)")
    }
    
    func onInterstitalClosed(_ apid: String, isCompleted: Bool) {
        print("adCashController interstitial closed \(isCompleted)")
    }
}

extension AdCashController: BannerAdWidgetDelegate{
    func onBannerLoaded(_ apid: String) {
        print("adCashController adCash bannerView Loader")
    }
    
    
}
