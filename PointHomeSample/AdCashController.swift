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
    
    let appId: String = "1cd2e20a33e941dd942940ac03891562"
    let appSecretKey: String = "c4b642121ee94d01"
    let APID: String = "55782ef7-68ac-4c1a-9342-929fe671fbbb"
    let InterAPID: String = "f43acc7d-273c-4747-a2d4-9a35bad705a09"
    let nativeAPID: String = "f499d84a-9a2c-464a-8c1b-ffd6e4d2392d"
    
    let adCashAppId: String = "ec79d136328c4aef9ddae0f2fd8ab514"
    let adCashAppSecretKey: String = "23bead48e1bb46d8"
    let adCashBanner: String = "eeb9997c-5528-4eed-aa89-849c57f5661f"
    
    let pointHomeAppId: String = "1cd2e20a33e941dd942940ac03891562"
    let pointHomeAppSecretKey: String = "c4b642121ee94d01"
    let pointHomeBanner: String = "55782ef7-68ac-4c1a-9342-929fe671fbbb"
    
    let dgAppId: String = "3b0d2a6fd8b74cd4a13c02b8079462c3"
    let dgAppSecretKey: String = "9ea781258f924e15"
    let dgImageNAM: String = "96b8102b-5eb1-4ca9-90be-72214071c881"
    let dgSmartNAM: String = "5a81a9c7-8e43-42c5-a49e-92bf844adb90"
    
    // 마이홈플러스 iOS Live Image 배너 - smart?
    let myHomePlusAppId: String = "68b388c0247e45c3afde2f14066d1d66"
    let myHomePlusAppSecretKey: String = "a6df264fbd6d4fec"
    let myHomePlusImageNAM: String = "6cbc862a-b671-45e5-a919-d58e61197560"
    
    let pinkAppId: String = "b2034cfe205d49f59667ca58f1193041"
    let pinkAppSecretKey: String = "d6c6674bf31544fa"
    let pink300250: String = "779fd451-f839-4892-a005-f4c7d1c45da0"
    
    var bannerLoader: BannerAdLoader! = nil
    
    var bannerAdView: BannerAdView?
    
    var interLoader: InterstitialAdLoader! = nil
    
    private var nativeLoader: NativeAdLoader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appIdLabel.text = "appId: \(adCashAppId)"
        self.appSecretKeyLabel.text = "appSecretKey: \(adCashAppSecretKey)"
        self.ApIdLabel.text = "APID: \(adCashBanner)"
        
        bannerLoader = BannerAdLoader(rootVC: self, placementId: dgSmartNAM, size: .DYNAMIC)
            .setConfig(appId: dgAppId, appSecretKey: dgAppSecretKey)
        bannerLoader.delegate = self
        
//        bannerLoader.setNAMNative { adPopcornSSPNativeAd, nib in
//            if let xibView = nib.instantiate(withOwner: nil, options: nil).first as? GFPNativeSimpleAdView {
//                print("xibView instantiate  success \(xibView)")
//                let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
//                apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
//                adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
//            }else{
//                print("xibView instantiate failed")
//            }
//        }

        bannerLoader.setNAMNative(type: .Smart, width: 300) { adPopcornSSPNativeAd, view in
            guard let xibView = view as? GFPNativeSimpleAdView else{
                print("Failed to cast UIView to GFPNativeSimpleAdView")
                return
            }
            print("xibView frame \(xibView.frame.width) \(xibView.frame.height)")
            let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
            apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
            adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
        }
        
//        bannerLoader.setNAMNative(type: .Smart, width: 300)
        
        bannerAdView = BannerAdView(frame: .zero).setConfig(appId: myHomePlusAppId, appSecretKey: myHomePlusAppSecretKey)
        bannerAdView?.setBannerAd(rootVC: self, placementId: myHomePlusImageNAM, size: .DYNAMIC)
        bannerAdView?.delegate = self
        
        let width: CGFloat = UIScreen.main.bounds.width
    
//        bannerAdView?.setNAMNative(type: .Image, width: width)
        
        if let bannerAdView = self.bannerAdView {
            self.bannerView.addSubview(bannerAdView)
        }
        
        
//        interLoader = InterstitialAdLoader(placementId: InterAPID, rootViewController: self)
//            .setConfig(appId: appId, appSecretKey: appSecretKey)
//        interLoader.delegate = self
    
    }
    
    @IBAction func requsetAdBtnAction(_ sender: Any) {
        bannerLoader.requestAd()
    }
    
    @IBAction func testBtnAction(_ sender: Any) {
        bannerAdView?.requestAd()
//        interLoader.requestAd()
    }
    

    @IBAction func stopAdBtnAction(_ sender: Any) {
        bannerAdView?.releaseAd()
    }
    
    deinit{
        print("[Buzzvil Test] deinit")
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
        
        self.bannerView.addSubview(adView)
    
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            adView.widthAnchor.constraint(equalToConstant: size.width),
            adView.heightAnchor.constraint(equalToConstant: size.height),
            adView.centerXAnchor.constraint(equalTo: self.bannerView.centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: self.bannerView.centerYAnchor)
        ])
        print("bannerView frame point \(self.bannerView.frame.origin.x) \(self.bannerView.frame.origin.y)")
        
        print("adView frame point \(adView.frame.origin.x) \(adView.frame.origin.y)")
        print("adView frame size \(adView.frame.width) \(adView.frame.height)")
//        adView.backgroundColor = .gray
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

//extension AdCashController: InterstitialAdDelegate{
//    func onInterstitalLoaded(_ apid: String) {
//        print("adCashController interstitial Loaded")
//    }
//    
//    func onInterstitalOpened(_ apid: String) {
//        print("adCashController interstitial opened")
//    }
//    
//    func onInterstitalClicked(_ apid: String) {
//        print("adCashController interstitial clicked")
//    }
//    
//    func onInterstitalFailed(_ apid: String, error: AdCashFramework.AdCashErrorModel) {
//        print("adCashControlleradCashController interstitial failed \(error.message)")
//    }
//    
//    func onInterstitalClosed(_ apid: String, isCompleted: Bool) {
//        print("adCashController interstitial closed \(isCompleted)")
//    }
//}

extension AdCashController: BannerAdWidgetDelegate{
    func onBannerLoaded(_ apid: String) {
        print("adCashController adCash bannerView Loader")
        
        print("bannerView size \(self.bannerAdView?.frame.size)")
    }
    
    
}
