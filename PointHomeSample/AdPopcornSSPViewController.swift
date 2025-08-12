//
//  AdPopcornSSPViewController.swift
//  PointHomeSample
//
//  Created by jun on 7/7/25.
//

import UIKit
import AdPopcornSSP

class AdPopcornSSPViewController: UIViewController, APSSPInterstitialVideoAdDelegate, APSSPInterstitialAdDelegate{
    
    let appKey: String = "732686956"
    let interstitialVideo: String = "uGWU9WrA25upW5d"
    let interstitial: String = "gXNo9q2G5J58coX"
    let InterstitialRewardVideo: String = "Dggt1vdAgtS65T1"
    var interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!
    var interstitialAd: AdPopcornSSPInterstitialAd!
    
    override func viewDidLoad() {
      super.viewDidLoad()
      interstitialVideoAd = AdPopcornSSPInterstitialVideoAd.init(key: appKey,
      placementId: interstitialVideo, viewController: self)
      interstitialVideoAd.delegate = self
      interstitialAd = AdPopcornSSPInterstitialAd.init(key: appKey, placementId: interstitial, viewController: self)
      interstitialAd.delegate = self
    }
    
    @IBAction func loadBtnAction(_ sender: Any) {
      interstitialVideoAd.loadRequest()
  //    interstitialAd.loadRequest()
    }
    
    // InterstitialVideoAd Delegate
    func apsspInterstitialVideoAdLoadSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
      print(":x:apsspInterstitialVideoAdLoadSuccess")
      interstitialVideoAd.present(from: self)
    }
    func apsspInterstitialVideoAdLoadFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!, error: AdPopcornSSPError!) {
      print(":x:apsspInterstitialVideoAdLoadFail error :\(error)")
    }
    func apsspInterstitialVideoAdShowSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
      print(":x:apsspInterstitialVideoAdShowSuccess")
    }
    func apsspInterstitialVideoAdShowFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
      print(":x:apsspInterstitialVideoAdShowFail")
    }
    func apsspInterstitialVideoAdClosed(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
      print(":x:apsspInterstitialVideoAdClosed")
    }
    // Interstitial Delegate
    func apsspInterstitialAdLoadSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
      print(":x:apsspInterstitialVideoAdLoadSuccess")
      interstitialAd.present(from: self)
    }
    func apsspInterstitialAdLoadFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
      print(":x:apsspInterstitialAdLoadFail erro \(error)")
    }
    func apsspInterstitialAdShowSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
      print(":x:apsspInterstitialAdShowSuccess")
    }
    func apsspInterstitialAdShowFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
      print(":x:apsspInterstitialAdShowFail")
    }
    func apsspInterstitialAdClosed(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
      print(":x:apsspInterstitialAdClosed")
    }
    func apsspInterstitialAdClicked(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
      print(":x:apsspInterstitialAdClicked")
    }
  }
