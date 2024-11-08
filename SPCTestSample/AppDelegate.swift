//
//  AppDelegate.swift
//  SPCTestSample
//
//  Created by 임재혁 on 2024/02/21.
//

import UIKit
import PointHome
import AvatyeAdCash

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // LIVE
//        PointHome.setting(appId: "35f2059b8b1c44048897ab16df3ad448", appSecretKey: "c13094d4fca94958", logLevel: .debug)
        
        // TEST
        PointHome.setting(appId: "af46ad7d30ea40f88ddf0d76345d89f9", appSecretKey: "18f4a1ec94574607", logLevel: .debug)
//        PointHome.setting(appId: "11244e15ccc643ca84a0ed954ffb9c78", appSecretKey: "f968b1e1089b48b3", logLevel: .debug)
//        let adCash = AdCashInit(appId: "01dfa01ea99e4ee9b4ee5c55782d4ad8", appSecretKey: "59780bfeaf74448c")
//        adCash.setAdCash(appKey: "614090651")
//        adCash.setLogLevel(logLevel: .debug)
//        
        // stage
//        PointHome.setting(appId: "83c3c7ea03874a889a10ed13b00b9655", appSecretKey: "8718ff74b7864aca", logLevel: .debug)
        
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

