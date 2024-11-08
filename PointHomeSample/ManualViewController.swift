//
//  ManualViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 5/21/24.
//

import UIKit

class ManualViewController: UIViewController, UITextFieldDelegate{
    
    // 대역 작성해줘야함.
    @IBOutlet weak var manualLabel: UILabel!
    
    @IBOutlet weak var appIdTextField: UITextField!
    
    @IBOutlet weak var appSecretKeyTextField: UITextField!
    
    @IBOutlet weak var userKeyTextField: UITextField!
    
    
    override func viewDidLoad(){
        self.view.backgroundColor = .white
        
        self.userKeyTextField.text = PHSelectInit.shared.userKey
        
        appIdTextField.delegate = self
        appSecretKeyTextField.delegate = self
        userKeyTextField.delegate = self
        
        if PHSelectInit.shared.modTage == 0 {
            self.manualLabel.text = "Manual / test 대역"
        } else {
            self.manualLabel.text = "Manual / stage 대역"
        }
        
        self.manualLabel.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    @IBAction func appIdTrashBtn(_ sender: Any) {
        PHSelectInit.shared.appId = nil
        self.appIdTextField.text = nil
    }
    
    @IBAction func appSecretKeyTrashBtn(_ sender: Any) {
        PHSelectInit.shared.appSecretKey = nil
        self.appSecretKeyTextField.text = nil
    }
    
    @IBAction func userKeyTrashBtn(_ sender: Any) {
        PHSelectInit.shared.userKey = nil
        self.userKeyTextField.text = nil
    }
    
    @IBAction func manualOpenBtn(_ sender: Any) {
        PHSelectInit.shared.appId = self.appIdTextField.text
        PHSelectInit.shared.appSecretKey = self.appSecretKeyTextField.text
        PHSelectInit.shared.userKey = self.userKeyTextField.text
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
