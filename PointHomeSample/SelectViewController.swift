//
//  SelectViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 4/25/24.
//

import UIKit
import AvatyePointHome
import AdCashFramework

class PHSelectInit{
    static let shared = PHSelectInit()
    
    var modTage: Int = 0
    var tag: Int = 0
    var testMode: Bool = false
    var acceptUser: Bool = true
    
    var appId: String? = nil
    var appSecretKey: String? = nil
    var userKey: String? = nil
    
    var openKey: String = "pointhome"
    
    private init(){}
}

class SelectViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var userKeyTextFiled: UITextField!
    
    @IBOutlet weak var openKeyTextFiled: UITextField!
    
    @IBOutlet var modeButtons: [UIButton]!
    
    @IBOutlet var radioButtons: [UIButton]!
    
    @IBOutlet weak var appIdLabel: UILabel!
    @IBOutlet weak var appIdStackView: UIStackView!
    
    @IBOutlet weak var userKeyLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modeButtons.forEach {
            $0.addTarget(self, action: #selector(self.modeButton(_:)), for: .touchUpInside)
        }
        
        self.radioButtons.forEach {
            $0.addTarget(self, action: #selector(self.radioButton(_:)), for: .touchUpInside)
        }
        
        userKeyTextFiled.resignFirstResponder()
        
//        appIdStackView.translatesAutoresizingMaskIntoConstraints = false
        
        userKeyTextFiled.delegate = self
        
    }
    
    @objc private func modeButton(_ sender: UIButton){
        print("mode 번호 : ", sender.tag)
        
        PHSelectInit.shared.modTage = sender.tag
        self.modeButtons.forEach {
            if $0.tag == sender.tag{
                if #available(iOS 13.0, *) {
                    $0.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                if #available(iOS 13.0, *) {
                    $0.setImage(UIImage(systemName: "circle"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        if sender.tag == 0 {
            AvatyePH.devModeChange(value: "test")
            AdCashInit.devModeChange(value: "test")
            print("pointHomeURL test")
        }else{
            AvatyePH.devModeChange(value: nil)
            AdCashInit.devModeChange(value: nil)
            print("pointHomeURL stage")
        }
    }
    
    @IBAction func switchBtnAction(_ sender: UISwitch) {
        if sender.isOn {
            print("switch on")
            AvatyePH.testModeChange(value: true)
            PHSelectInit.shared.testMode = true
        }else{
            print("switch on")
            AvatyePH.testModeChange(value: false)
            PHSelectInit.shared.testMode = false
        }
    }
    
    @objc private func radioButton(_ sender: UIButton){
        print("태그 번호 : ", sender.tag)
        
        PHSelectInit.shared.tag = sender.tag
        
        // UIButton 반복
        self.radioButtons.forEach {
            // sender로 들어온 버튼과 tag를 비교
            if $0.tag == sender.tag {
                // 같은 tag이면 색이 찬 동그라미로 변경
                if #available(iOS 13.0, *) {
                    $0.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                // 다른 tag이면 색이 없는 동그라미로 변경
                if #available(iOS 13.0, *) {
                    $0.setImage(UIImage(systemName: "circle"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @IBAction func openAction(_ sender: Any) {
        PHSelectInit.shared.appId = nil
        PHSelectInit.shared.appSecretKey = nil
        if openKeyTextFiled.text != ""{
            PHSelectInit.shared.openKey = openKeyTextFiled.text!
        }else{
            PHSelectInit.shared.openKey = "pointhome"
        }
        
        
        // userKey
        if PHSelectInit.shared.tag == 1{
            PHSelectInit.shared.userKey = nil
        }else{
            PHSelectInit.shared.userKey = userKeyTextFiled.text
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if PHSelectInit.shared.tag == 2{
            if let manualViewController = storyboard.instantiateViewController(withIdentifier: "manualViewController") as? UIViewController{
                navigationController?.pushViewController(manualViewController, animated: true)
            }
        }else{
            if let viewController = storyboard.instantiateViewController(withIdentifier: "viewController") as? UIViewController{
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    
    // userKey trashbtn
    @IBAction func trashBtn(_ sender: Any) {
        PHSelectInit.shared.userKey = nil
        self.userKeyTextFiled.text = nil
    }
    
    // 키보드 done 눌렀을때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

     // 화면을 터치할 때 호출되는 함수
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         // 화면을 터치하면 키보드를 내리는 동작
         view.endEditing(true)
     }
 }
