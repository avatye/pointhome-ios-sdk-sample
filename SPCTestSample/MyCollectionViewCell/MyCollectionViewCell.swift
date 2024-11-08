//
//  MyCollectionViewCell.swift
//  SPCTestSample
//
//  Created by 임재혁 on 8/20/24.
//

import UIKit
import PointHome

class MyCollectionViewCell: UICollectionViewCell {
    
    var deviceID: String!
    var placementID: String!
    var advertiseID: String!
    var IDFA: String!

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var reward: UILabel!
    
    var landingUrl: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepare(placementID: String, advertiseID: String, deviceID: String, icon: String, title: String, image: String, reward: Int, landingUrl: String, IDFA: String){
        self.deviceID = deviceID
        self.placementID = placementID
        self.advertiseID = advertiseID
        self.landingUrl = landingUrl
        self.IDFA = IDFA
        
        if let iconUrl = URL(string: icon){
            self.icon.loadImage(from: iconUrl)
        }
        
        self.title.text = title
        
        if let imageUrl = URL(string: image){
            self.image.loadImage(from: imageUrl)
        }
        
        self.reward.text = "\(reward) 원"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.image.isUserInteractionEnabled = true
        self.image.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func imageTapped(){
        guard let urlString = landingUrl, let url = URL(string: urlString) else {
            print("landing url error")
            return
        }
        UIApplication.shared.open(url, options: [:]) { result in
            if result {
                print("12312321 \(result)")
                PointHomeADS().postADSClick(userKey: self.deviceID,
                                            placementID: self.placementID,
                                            advertiseID: self.advertiseID,
                                            deviceADID: self.IDFA) {
                    result in
                    DispatchQueue.main.async{
                        switch result {
                        case .success(let item):
                            print("item \(item)")
                            self.title.text = "성공"
                        case .failure(let error):
                            print("error \(error)")
                            self.title.text = "실패"
                        }
                    }
                }
            }
        }
    }

}
