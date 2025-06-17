//
//  SelectViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 4/25/24.
//

import UIKit
import AvatyePointHome
import AdCashFramework
import DropDown

class PHSelectInit{
    static let shared = PHSelectInit()
    
    var modTag: Int = 0
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
    
    // userKey
    @IBOutlet weak var userKeyTextFiled: UITextField!
    // openKey
    @IBOutlet weak var openKeyTextFiled: UITextField!
    // 대역 버튼
    @IBOutlet var modeButtons: [UIButton]!
    // DropDown View / text
    @IBOutlet weak var appDropDownView: UIView!
    @IBOutlet weak var appDropDownText: UILabel!
    // trashButton
    @IBOutlet weak var trashBtn: UIButton!
    
    // test대역 DropDown item
    let testAppItems = ["Channeling", "CashButton", "하나머니"]
    // stage대역 DropDown item
    let stageAppItems = ["Channeling", "CashButton", "하나머니", "다이렉트", "OCB", "Syrup", "발로소득", "야핏무브", "머니트리", "하루날씨"]
    
    // appItem index
    var appIndex = 0
    
    let dropdown = DropDown()
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trashBtn.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        
        self.modeButtons.forEach {
            $0.addTarget(self, action: #selector(self.modeButton(_:)), for: .touchUpInside)
        }

        userKeyTextFiled.resignFirstResponder()
        userKeyTextFiled.delegate = self
        
        self.setDropDown()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownBtnAction))
        self.appDropDownView.isUserInteractionEnabled = true
        self.appDropDownView.addGestureRecognizer(tapGesture)
    }
    
    // 다크모드 및 라이트모드 전환 함수.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 다크모드 or 라이트모드 전환 시 호출됨
            print("darkMode or LightMode change")
            self.trashBtn.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    // MARK: - FUNC
    private func setDropDown(){
        dropdown.cellHeight = 40 // cell Height
        dropdown.cornerRadius = 5.0 // cell radius
        dropdown.backgroundColor = .systemGray6 // cell backGround
        dropdown.shadowOffset = CGSize(width: 0, height: 10) // cell Shadow
        
        dropdown.separatorColor = .clear // item 구분선

        dropdown.anchorView = self.appDropDownView // dropDown 어떤 view?
        dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView?.plainView.bounds.height)!)
        
        dropdown.direction = .bottom
        dropdown.offsetFromWindowBottom = 200
    }
    
    
    @objc private func modeButton(_ sender: UIButton){
        print("mode 번호 : ", sender.tag)
        
        if PHSelectInit.shared.modTag != sender.tag {
            self.appIndex = 0
            self.appDropDownText.text = "선택하세요."
            PHSelectInit.shared.modTag = sender.tag
            
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
            }else{
                AvatyePH.devModeChange(value: nil)
                AdCashInit.devModeChange(value: nil)
            }
        }
        
    }
    
    @objc private func dropDownBtnAction(_ sender: UIButton){
        dropdown.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        dropdown.dataSource = PHSelectInit.shared.modTag == 0 ? testAppItems : stageAppItems
        
        dropdown.show() // 드랍다운 보여주기

        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            // 항목 선택시 작동
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            // 해당 뷰에서 어떻게 할건지 선택가능
            self.appDropDownText.text = item
            self.appIndex = index

        }
    }
    
    // MARK: - Click Event
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
    
    @IBAction func openAction(_ sender: Any) {
        
        PHSelectInit.shared.appId = nil
        PHSelectInit.shared.appSecretKey = nil
        PHSelectInit.shared.tag = self.appIndex
        
        if openKeyTextFiled.text != ""{
            PHSelectInit.shared.openKey = openKeyTextFiled.text!
        }else{
            PHSelectInit.shared.openKey = "pointhome"
        }
        
        if [1,9].contains(self.appIndex) || userKeyTextFiled.text == ""{
            PHSelectInit.shared.userKey = nil
        }else{
            PHSelectInit.shared.userKey = userKeyTextFiled.text
        }
        
    }
    
    @IBAction func trashBtn(_ sender: Any) {
        PHSelectInit.shared.userKey = nil
        self.userKeyTextFiled.text = nil
    }
    
    // MARK: - KeyBoard Func
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
