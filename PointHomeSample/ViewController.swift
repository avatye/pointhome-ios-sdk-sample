//
//  ViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 2023/07/14.
//

import UIKit
import AdSupport
import AvatyePointHome
import ActivityKit
import WebKit
import GFPSDK

struct AppCredential{
    let appId: String
    let appSecretKey: String
}

class ViewController: UIViewController{
    
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var appIdLabel: UILabel!
    
    @IBOutlet weak var appSecretKeyLabel: UILabel!
    
    @IBOutlet weak var userKeyLabel: UILabel!
    
    
    let uuid: String = UIDevice.current.identifierForVendor!.uuidString
    let IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    
    var openBool: Bool = false
    
    var appID: String = ""
    var appSecretKey: String = ""
    
    var pointHomeService: AvatyePHService! = nil
    
    let profileLabel: UILabel = UILabel()
    
    var floatingButton: UIButton! = nil
    
    let qaAppCredentials: [AppCredential] = [
        // 채널링
        AppCredential(appId: "16a99b26a7f64be4b512f4e82d972a5a", appSecretKey: "a27984cf4bca4194"),
        // 게스트
        AppCredential(appId: "1cd2e20a33e941dd942940ac03891562", appSecretKey: "c4b642121ee94d01"),
        // 하나머니 ( 캐시블럭 )
        AppCredential(appId: "1fdf009984be47a397bda32873a239ef", appSecretKey: "806e8cfffac34a92")
    ]
    
    let liveAppCredentials: [AppCredential] = [
        // 채널링
        AppCredential(appId: "844a3ea8c7a548dbb42adefd4fb0db87", appSecretKey: "3b4e4421d41c4de3"),
        // 게스트
        AppCredential(appId: "93a584254434475eb9d140986e9da8cb", appSecretKey: "03a4998cbcce4ca8"),
        // 하나머니
        AppCredential(appId: "3bb8b37b85484a66b1b8c9dd61d37efd", appSecretKey: "268a8788740c4a6c"),
        // 다이렉트
        AppCredential(appId: "aa51f3d766664030a1b59b950248d586", appSecretKey: "86ae7245943f4166"),
        // OCB
        AppCredential(appId: "38d562c948274074b409b81e48cf8f26", appSecretKey: "087bbae957554644"),
        // Syrup
        AppCredential(appId: "cccafade179b4c17be03ce7dc45849be", appSecretKey: "08d4cdb14d9e4318"),
        // 발로소득
        AppCredential(appId: "d3a74845654442c38a77a1579c94e078", appSecretKey: "cef49849f8474bd7"),
        // 야핏무브
        AppCredential(appId: "c6384bfb126d40348501fd35b288e505", appSecretKey: "eeaa794399d74852"),
        // 머니트리
        AppCredential(appId: "248290af6356445fb5d53d305122562a", appSecretKey: "4db8ea35e620494d"),
        // 하루날씨
        AppCredential(appId: "bf0b6002cfa911e98c2a1ce62f357dd5", appSecretKey: "8c2a1ce62f357dd5"),
    ]
    
    let convertClosure: (String) async throws -> String = { stringValue in
        do{
            let resultCode = try await ExchangeService().serverAction(transactionID: stringValue, type: .verify)
            print("resultCode \(resultCode)")
            return resultCode
        }catch{
            print("error occurred \(error)")
            return "9999"
        }
    }
    
    let acceptClosure: (String) async throws -> acceptedUserModel = { userValue in
        do{
            let result = try await AcceptedAgeService().AgeCheckService(userKey: userValue)
            print("acceptClosure Success result \(result)")
            return result
        }catch{
            print("acceptClosure Error")
            return acceptedUserModel(usable: false, message: "erorr 입니다.")
        }
    }
    
    let covertCompletion: (String, @escaping (Result<String, Error>) -> Void) -> Void = { stringValue, completion in
        ExchangeService().exchangeCompletion(transactionID: stringValue, type: .verify) { result in
            switch result {
            case .success(let resultCode):
                completion(.success(resultCode))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    var adBool: Bool = false
    
    override func viewDidLoad() {
        print("uuid \(uuid)")
        // test
        if PHSelectInit.shared.modTag == 0 {
            self.modeLabel.text = "대역 : TEST"
            
            self.appID = qaAppCredentials[PHSelectInit.shared.tag].appId
            self.appSecretKey = qaAppCredentials[PHSelectInit.shared.tag].appSecretKey
            
            print("test appId \(appID) appSecretKey \(appSecretKey)")
        }else{
            // stage
            self.modeLabel.text = "대역 : LIVE"
            
            self.appID = liveAppCredentials[PHSelectInit.shared.tag].appId
            self.appSecretKey = liveAppCredentials[PHSelectInit.shared.tag].appSecretKey
            
            print("Live appId \(appID) appSecretKey \(appSecretKey)")
        }
        
        if PHSelectInit.shared.testMode{
            self.appIdLabel.text = "AppID: \(self.replaceLast4DigitsWithTEST(appID: self.appID))"
            self.appSecretKeyLabel.text = "AppSecretKey: \(self.appSecretKey)"
            if let userKey = PHSelectInit.shared.userKey {
                self.userKeyLabel.text = "UserKey: \(userKey)"
            }else{
                self.userKeyLabel.text = "UserKey: \(self.uuid)"
            }
            PHSelectInit.shared.appId = self.replaceLast4DigitsWithTEST(appID: self.appID)
            PHSelectInit.shared.appSecretKey = self.appSecretKey
        }else{
            self.appIdLabel.text = "AppID: \(self.appID)"
            self.appSecretKeyLabel.text = "AppSecretKey: \(self.appSecretKey)"
            if let userKey = PHSelectInit.shared.userKey {
                self.userKeyLabel.text = "UserKey: \(userKey)"
            }else{
                self.userKeyLabel.text = "UserKey: \(self.uuid)"
            }
            PHSelectInit.shared.appId = self.appID
            PHSelectInit.shared.appSecretKey = self.appSecretKey
        }
        
        super.viewDidLoad()
        
        if PHSelectInit.shared.userKey == nil {
            pointHomeService = AvatyePHService(rootViewController: self, appId: appID, appSecretKey: appSecretKey, userKey: PHSelectInit.shared.userKey, openKey: PHSelectInit.shared.openKey, fullScreen: false)
        }else{
            print("PHSelectInit openkey \(PHSelectInit.shared.openKey)")
            pointHomeService = AvatyePHService(rootViewController: self, appId: appID, appSecretKey: appSecretKey, userKey: PHSelectInit.shared.userKey, openKey: PHSelectInit.shared.openKey, fullScreen: false)
        }
        self.pointHomeService.delegate = self
//        pointHomeService.setCashButton(bottom: 330, trailing: 100)
        pointHomeService.setCashButton()
        
        let _: String = pointHomeService.getUserAgent()
        
        pointHomeService.convertFunc(convert: convertClosure)
//        pointHomeService.acceptUserFunc(closure: acceptClosure)
        
//        pointHomeService.GFPAdManagerRegisterFunc { webView in
//            PointHomeLogger.debug("pointHomeService GFPAdManagerRegisterFunc")
//            GFPAdManager.register(webView)
//            GFPAdManager.examineWebViewStatus(webView) { javaScriptError, results in
//                let isRegistered = results["isRegistered"] as? Bool ?? false
//                PointHomeLogger.debug("pointHomeService GFPAdManagerRegisterFunc examineWebViewStatus isRegistered \(isRegistered)")
//            }
//            
//        }
    }
    
    func replaceLast4DigitsWithTEST(appID: String) -> String {
        let pattern = ".{4}$" // 마지막 4자리를 나타내는 정규식 패턴
        let replacement = "TEST" // 대체할 문자열
        
        if appID.count < 4 {
            // 입력된 문자열이 4자리보다 짧으면 그대로 반환
            return appID
        }
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: appID.utf16.count)
            return regex.stringByReplacingMatches(in: appID, range: range, withTemplate: replacement)
        } catch {
            PointHomeLogger.debug("Error: Invalid regular expression")
            return appID
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear dismiss")
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func phBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        pointHomeService.openPointHome { result in
            switch result {
            case .success(let t):
                print("pointHome open success \(t)")
                self.openBool = false
            case .failure(let e):
                print("pointHome open failure \(e)")
                self.openBool = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PointHomeLogger.debug("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        PointHomeLogger.debug("viewWillDisappear")
    }


    @IBAction func sStriptBanner(_ sender: Any) {
        AvatyePH.getUserProfile(appId: self.appID, appSecretKey: self.appSecretKey, userKey: PHSelectInit.shared.userKey) {
            result in
            switch result {
            case .success(let item):
                DispatchQueue.main.async{
                    if let nickname = item.profile?.nickname {
                        self.profileLabel.text = "getUserProfile : \(nickname)"
                        print("item \(nickname)")
                    } else {
                        self.profileLabel.text = "getUserProfile : success but none"
                        print("item success but none")
                    }
                    self.profileLabel.font = UIFont.systemFont(ofSize: 18)
                    self.profileLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(self.profileLabel)
                    
                    NSLayoutConstraint.activate([
                        self.profileLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
                        self.profileLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12)
                    ])
                }
            case .pathErr:
                print("getUserProfile pathErr")
            case .serverErr:
                print("getUserProfile serverErr")
            case .inMaintenance:
                print("getUserProfile inMaintenance")
            case .networkFail:
                print("getUserProfile networkFail")
            case .unRecognizedError:
                print("getUserProfile unRecognizedError")
            case .expireToken:
                print("getUserProfile expireToken")
            case .notAgreed:
                print("getUserProfile notAgreed")
            }
        }
        
    }
    
}

extension ViewController: AvatyePHDelegate{
    // custom 변경.
    func pointHomeEventListener(event: String) {
        pointHomeService.sendMessage(message: "1111")
        PointHomeLogger.debug("pointHomeEventListener \(event)")
    }
    
    func pointHomeSystemEventListener(event: String) {
        PointHomeLogger.debug("pointHomeSystemEventListener \(event)")
        // close 함수 테스트
        
        if let jsonData = event.data(using: .utf8){
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    print("system event json 파싱")
                    print("system id : \(jsonObject["id"])")
                    print("system key : \(jsonObject["key"])")
                    print("system value : \(jsonObject["value"])")
                    if jsonObject["id"] as? String == "default"{
//                        self.pointHomeService.closePointHome {
//                            print("closed")
//                            self.pointHomeService = nil
//                        }
                    }
                }
            } catch {
                print("system event json 파싱 오류")
            }
        }
    }
    
    func pointHomeSliderClosed(caller: String) {
        PointHomeLogger.debug("pointHome Slider Closed \(caller)")
        openBool = false
    }
    
    func pointHomeSliderOpened(caller: String) {
        PointHomeLogger.debug("pointHome slider Opend \(caller)")
        openBool = false
    }
    
}
