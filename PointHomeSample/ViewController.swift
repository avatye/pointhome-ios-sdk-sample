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
        // test
        if PHSelectInit.shared.modTage == 0 {
            self.modeLabel.text = "대역 : TEST"
            
            switch PHSelectInit.shared.tag{
            case 0:
                // 채널링
                self.appID = "16a99b26a7f64be4b512f4e82d972a5a"
                self.appSecretKey = "a27984cf4bca4194"
            case 1:
                // Default
                self.appID = "1cd2e20a33e941dd942940ac03891562"
                self.appSecretKey = "c4b642121ee94d01"
            case 2:
                // Manual
                self.appID = PHSelectInit.shared.appId ?? ""
                self.appSecretKey = PHSelectInit.shared.appSecretKey ?? ""
                if PHSelectInit.shared.userKey == "" {
                    PHSelectInit.shared.userKey = nil
                }
                print("test appId \(appID) appSecretKey \(appSecretKey)")
            default:
                print("test tag Error")
            }
        }else{
            // stage
            self.modeLabel.text = "대역 : LIVE"
            
            switch PHSelectInit.shared.tag{
            case 0:
                // 채널링
                self.appID = "844a3ea8c7a548dbb42adefd4fb0db87"
                self.appSecretKey = "3b4e4421d41c4de3"
            case 1:
                // Default
                self.appID = "93a584254434475eb9d140986e9da8cb"
                self.appSecretKey = "03a4998cbcce4ca8"
            case 2:
                // manual
                self.appID = PHSelectInit.shared.appId ?? ""
                self.appSecretKey = PHSelectInit.shared.appSecretKey ?? ""
                if PHSelectInit.shared.userKey == "" {
                    PHSelectInit.shared.userKey = nil
                }
                print("stage appId \(appID) appSecretKey \(appSecretKey)")
            default:
                // error
                print("stage tag Error")
            }
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
            pointHomeService = AvatyePHService(rootViewController: self, appId: appID, appSecretKey: appSecretKey, userKey: PHSelectInit.shared.userKey, fullScreen: true)
        }else{
            pointHomeService = AvatyePHService(rootViewController: self, appId: appID, appSecretKey: appSecretKey, userKey: PHSelectInit.shared.userKey, fullScreen: true)
        }
        self.pointHomeService.delegate = self
        pointHomeService.setCashButton()
        
        let _: String = pointHomeService.getUserAgent()
        
        pointHomeService.convertFunc(convert: convertClosure)
        pointHomeService.acceptUserFunc(closeure: acceptClosure)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func didEnterBackground(){
        print("didEnterBackground")
    }
    
    @objc func willEnterForeground(){
        print("willEnterForeground")
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
        
//        if pointHomeService != nil{
//            self.pointHomeService.removePHService()
//            self.pointHomeService = nil
//        }
        
//        NotificationCenter.default.removeObserver(self)
        
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
        AvatyePH.getUserProfile(appId: self.appID, appSecretKey: self.appSecretKey, userKey: "123", resource: "profile") {
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
//            print("pointHomeSlider open alert")
//            showTopmostAlert()
//        }
        
        func showTopmostAlert() {
            if let topViewController = getTopViewController() {
                let alert = UIAlertController(title: "알림", message: "최상위 뷰 컨트롤러에서 표시된 메시지입니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                topViewController.present(alert, animated: true, completion: nil)
            }
        }

        // 최상위 뷰 컨트롤러를 찾는 함수
        func getTopViewController() -> UIViewController? {
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                return nil
            }
            return getTopViewController(from: rootViewController)
        }

        // 재귀적으로 최상위 뷰 컨트롤러를 찾는 함수
        func getTopViewController(from viewController: UIViewController) -> UIViewController? {
            if let presentedViewController = viewController.presentedViewController {
                return getTopViewController(from: presentedViewController)
            }
            if let navigationController = viewController as? UINavigationController {
                return getTopViewController(from: navigationController.visibleViewController ?? viewController)
            }
            if let tabBarController = viewController as? UITabBarController {
                return getTopViewController(from: tabBarController.selectedViewController ?? viewController)
            }
            return viewController
        }
        
        
    }
    
}
