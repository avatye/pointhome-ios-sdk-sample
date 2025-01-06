//
//  AppDelegate.swift
//  PointHomeSample
//
//  Created by 임재혁 on 2023/07/14.
//

import UIKit
import AdSupport
import AppTrackingTransparency
import AvatyePointHome
import BackgroundTasks
import AdCashFramework
#if canImport(GFPSDK)
import GFPSDK
#endif
#if canImport(BuzzvilSDK)
import BuzzvilSDK
#endif
#if canImport(AppLovinSDK)
import AppLovinSDK
#endif
#if canImport(PAGAdSDK)
import PAGAdSDK
#endif
#if canImport(VungleAdsSDK)
import VungleAdsSDK
#endif
#if canImport(MTGSDK)
import MTGSDK
#endif
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let appId = "7686ed203d5546f093f5be626833a24d"
        let appSecretKey = "994bb30d95f840fb"
        
        // mult appID
        AvatyePH.initialize(appId: appId, appSecretKey: appSecretKey, logLevel: .debug)
        
        AdCashInit.setting(appId: appId, appSecretKey: appSecretKey, logLevel: .debug)
        
        // test appId
//        AvatyePH.initialize(appId: "1cd2e20a33e941dd942940ac03891562", appSecretKey: "c4b642121ee94d01",logLevel: .debug)
        
        // stage appID
//        AvatyePH.initialize(appId: "93a584254434475eb9d140986e9da8cb", appSecretKey: "03a4998cbcce4ca8", logLevel: .debug)
        
        
//        AdCashInit.setting(appId: adCashAppId, appSecretKey: adCashAppSecretKey, logLevel: .debug)
        
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("notDetermined")
                case .restricted:
                    print("restricted")
                case .denied:
                    print("denied")
                case .authorized:
                    print("authorized idfa \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
                @unknown default:
                    print("error")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        if let adSetting = CaulyAdSetting.global() {
            CaulyAdSetting.setLogLevel(CaulyLogLevelDebug)
            adSetting.appId = "868410196"
            adSetting.appCode = "wAsKi1r6"
            adSetting.animType = CaulyAnimNone
            adSetting.closeOnLanding = true
        } else {
            print("Cauly Setting none")
        }

        #if canImport(GFPSDK)
        GFPAdManager.setup(withPublisherCd: "7976096509", target: self) { error in
            if let error = error {
                print("gfp ad mananger erro \(error)")
            } else {
                print("gfp ad Mananger none")
            }
        }
        #endif
        
        #if canImport(AppLovinSDK)
        let sdkKey = "nPNmWdnX7aDsJQd7yPG7w-rzdTAJJ3qcBNpgSoWzDrm4bUMSmHZJsv-2XRTSiOItVTm7FWZ7PrkUEKeVvlomd1"
        let initConfig = ALSdkInitializationConfiguration(sdkKey: sdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
        }
        #endif
        
        #if canImport(PAGAdSDK)
        let config = PAGConfig.share()
        config.appID = "8108172"
        PAGSdk.start(with: config) { pSuccess, error in
            if pSuccess {
                print("PAG Success")
            }
        }
        #endif
        
        #if canImport(VungleAdsSDK)
        VungleAds.initWithAppId("63db2422c08b2ab6cfe8cd58") { error in
            if let error = error {
                print("vungle error")
            }else {
                print("vungle init success")
            }
        }
        
        if VungleAds.isInitialized(){
            print("Vungle SDK is initialized")
        }else{
            print("Vungle SDK is Not initialized")
        }
        #endif
            
        #if canImport(MTGSDK)
        MTGSDK.sharedInstance().setAppID("292050", apiKey: "2f23f5c5f0cc24455e0b5a73067c96ff")
        #endif
        
        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start { result in
            print("googleAdManager initalize \(result)")
        }
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["00beb564b8cd75ddf87d3f8cf852cd0c"]
        #endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


#if canImport(GFPSDK)
extension AppDelegate: GFPAdManagerDelegate{
    //GFPAdManagerDelegate
    func attStatus() -> GFPATTAuthorizationStatus {
        if #available(iOS 14.5, *) {
          func convertATTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) -> GFPATTAuthorizationStatus {
            switch status {
            case .authorized:
              return .authorized
            case .denied:
              return .denied
            case .notDetermined:
              return .notDetermined
            case .restricted:
              return .restricted
            @unknown default:
              return .restricted
            }
          }
          return convertATTrackingStatus(ATTrackingManager.trackingAuthorizationStatus)
        } else {
          if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return .authorized
          }
          return .notDetermined
        }
      }
}
#endif

