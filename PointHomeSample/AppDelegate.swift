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
#if canImport(CaulySDK)
import CaulySDK
#endif
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
        
        let appId = "1cd2e20a33e941dd942940ac03891562"
        let appSecretKey = "c4b642121ee94d01"
        
        // mult appID
        AvatyePH.initialize(appId: appId, appSecretKey: appSecretKey, logLevel: .debug)
        
        AdCashInit.setting(appId: appId, appSecretKey: appSecretKey, logLevel: .debug)
        
//        AdCashMediation().initializeGAM()
        
//        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["B3152E49-63B3-4013-9144-2157D74CCD0B"]
        
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
        
        AvatyePH.initializeAppLovin("nPNmWdnX7aDsJQd7yPG7w-rzdTAJJ3qcBNpgSoWzDrm4bUMSmHZJsv-2XRTSiOItVTm7FWZ7PrkUEKeVvlomd1")
        
        AvatyePH.initializePangle("8108172")
        
        AvatyePH.initializeVungle("63db2422c08b2ab6cfe8cd58")
        
        #if canImport(GFPSDK)
        GFPAdManager.setup(withPublisherCd: "7976096509", target: self) { error in
            if let error = error {
                print("gfp ad mananger erro \(error)")
            } else {
                print("gfp ad Mananger none")
            }
        }
        #endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

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

