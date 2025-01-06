//
//  PointHomeCollectionViewCell.swift
//  PointHomeSample
//
//  Created by 임재혁 on 11/22/24.
//

import UIKit
import AdCashFramework

class PointHomeCollectionViewCell: UICollectionViewCell {
    
    var adView: UIView! = nil
    var bannerAdLoader: BannerAdLoader! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepare(rootVC: UIViewController, placementId: String){
        print("pointHomeCollect prpare")
//        self.backgroundColor = .blue
        if self.adView == nil {
            print("pointHomeCollect requestAd" )
            
            self.bannerAdLoader = BannerAdLoader(rootVC: rootVC, placementId: placementId, size: .DYNAMIC)
                .setConfig(appId: "af46ad7d30ea40f88ddf0d76345d89f9", appSecretKey: "18f4a1ec94574607")
            self.bannerAdLoader.delegate = self
            
//            self.bannerAdLoader.setNAMNative { adPopcornSSPNativeAd, nib in
//                if let xibView = nib.instantiate(withOwner: nil, options: nil).first as? GFPNativeSimpleAdView {
//                    print("xibView instantiate  success \(xibView)")
//                    let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
//                    apNAMNativeAdRenderer.namNativeSimpleAdView = xibView
//                    adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: xibView)
//                }else{
//                    print("xibView instantiate failed")
//                }
//            }
            
            self.bannerAdLoader.requestAd()
        }
    }

}

extension PointHomeCollectionViewCell: BannerAdLoaderDelegate{
    func onBannerLoaded(_ apid: String, adView: UIView, size: CGSize) {
        print("onBannerLoaded")
        self.adView = adView
        
        self.addSubview(adView)
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            adView.widthAnchor.constraint(equalToConstant: size.width),
            adView.heightAnchor.constraint(equalToConstant: size.height),
            adView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        print("adView frame point \(adView.frame.origin.x) \(adView.frame.origin.y) \(size.width) \(size.height)")
    }
    
    func onBannerFailed(_ apid: String, error: AdCashFramework.AdCashErrorModel) {
        print("adCashController adCash onBannerFailed \(error.code)")
        print("adCashController adCash onBannerFailed \(error.desc)")
    }
    
    func onBannerClicked(_ apid: String) {
        print("adCashController adCash onBannerClicked")
    }
    
    func onBannerRemoved(_ apid: String) {
        print("adCashController adCash onBannerRemoved")
    }
    
    
}
