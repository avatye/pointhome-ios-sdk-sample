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
    
    let adCashAppId: String = "0ff121d0b7b24d04b27b0efa9d162656"
    let adCashAppSecretKey: String = "9f30be8f57b34e44"
    let adCashBanner: String = "1a652ca9-8fbb-4b64-b13c-af431319e549"
    
    var bannerLoader: BannerAdLoader! = nil
    
    var bannerAdView: BannerAdView! = nil
    
    var interLoader: InterstitialAdLoader! = nil
    
    private var nativeLoader: NativeAdLoader! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appIdLabel.text = "appId: \(adCashAppId)"
        self.appSecretKeyLabel.text = "appSecretKey: \(adCashAppSecretKey)"
        self.ApIdLabel.text = "APID: \(adCashBanner)"
        
        bannerLoader = BannerAdLoader(rootVC: self, placementId: adCashBanner, size: .DYNAMIC)
            .setConfig(appId: adCashAppId, appSecretKey: adCashAppSecretKey)
        bannerLoader.delegate = self
        
        bannerLoader.setNAMNative { adPopcornSSPNativeAd, nib in
            if let xibView = nib.instantiate(withOwner: nil, options: nil).first as? GFPNativeSimpleAdView {
                print("xibView instantiate  success \(xibView)")
                let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
                apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
                adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
            }else{
                print("xibView instantiate failed")
            }
        }
//        bannerLoader.setNAMNative(type: .Image, width: 200) { adPopcornSSPNativeAd, view in
//            guard let xibView = view as? GFPNativeSimpleAdView else{
//                print("Failed to cast UIView to GFPNativeSimpleAdView")
//                return
//            }
//            print("xibView frame \(xibView.frame.width) \(xibView.frame.height)")
//            let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
//            apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
//            adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
//        }
        
        
        bannerAdView = BannerAdView(frame: .zero).setConfig(appId: adCashAppId, appSecretKey: adCashAppSecretKey)
        bannerAdView.setBannerAd(rootVC: self, placementId: adCashBanner, size: .DYNAMIC)
        bannerAdView.delegate = self
        
//        bannerAdView.setNAMNAtive(type: .Smart, width: 200) { adPopcornSSPNativeAd, view in
//            guard let xibView = view as? GFPNativeSimpleAdView else{
//                print("Failed to cast UIView to GFPNativeSimpleAdView")
//                return
//            }
//            print("xibView frame \(xibView.frame.width) \(xibView.frame.height)")
//            let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
//            apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
//            adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
//        }
        
        self.bannerView.addSubview(self.bannerAdView)
        
        
        interLoader = InterstitialAdLoader(placementId: InterAPID, rootViewController: self)
            .setConfig(appId: appId, appSecretKey: appSecretKey)
        interLoader.delegate = self
    
    }
    
    @IBAction func requsetAdBtnAction(_ sender: Any) {
        bannerLoader.requestAd()
//        bannerAdView.requestAd()
    }
    
    @IBAction func testBtnAction(_ sender: Any) {
//        bannerAdView.requestAd()
        bannerLoader.removeAd()
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
        
        self.bannerView.addSubview(adView)
        
//        adView.frame = CGRect(x: 0, y: 0, width: ewidth, height: eheight)
    
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
        adView.backgroundColor = .gray
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
        
        print("bannerView size \(self.bannerAdView.frame.size)")
//        self.bannerAdView.backgroundColor = .black
    }
    
    
}
