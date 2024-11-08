//
//  PHAdsViewController.swift
//  SPCTestSample
//
//  Created by 임재혁 on 7/16/24.
//

import UIKit
import PointHome
import AdSupport

struct MyModel {
    let title: String
    let iconUrl: String?
    let imageUrl: String?
    let reward: Int?
    let landingUrl : String?
    let placementID: String?
    let advertiseID: String?
    let deviceID: String?
    let IDFA: String?
}

class PHAdsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.myCollectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        let adItem = adItems[indexPath.row]
        cell.prepare(placementID: adItem.placementID ?? "", advertiseID: adItem.advertiseID ?? "", deviceID: adItem.deviceID ?? "", icon: adItem.iconUrl ?? "", title: adItem.title, image: adItem.imageUrl ?? "", reward: adItem.reward ?? 0, landingUrl: adItem.landingUrl ?? "", IDFA: adItem.IDFA ?? "")
        return cell
    }
    
    
    @IBOutlet weak var adView: UIView!
    let appID: String = "af46ad7d30ea40f88ddf0d76345d89f9"
    let uuid: String = UIDevice.current.identifierForVendor!.uuidString
    let IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    let userKey: String = "123"
    
    let placementID:String = "eecea398-3ffa-443c-9584-cf0dd84f34a0"
    
    var advertiseID: String! = nil
    
    @IBOutlet weak var appIDLabel: UILabel!
    @IBOutlet weak var placementLabel: UILabel!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var impressionLabel: UILabel!
    @IBOutlet weak var clickLabel: UILabel!
    
    var landingUrl: String?
    
    var adItems: [MyModel] = []
    
    private enum Const {
        static let itemSize = CGSize(width: 300, height: 400)
        static let itemSpacing = 24.0

        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - Self.itemSize.width) / 2.0
        }

        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: Self.insetX, bottom: 0, right: Self.insetX)
        }
    }


    // in ViewController
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Const.itemSize // <-
        layout.minimumLineSpacing = Const.itemSpacing // <-
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        print("uuid : \(self.uuid)")
        print("adid : \(self.IDFA)")
        
        self.myCollectionView.dataSource = self
        self.myCollectionView.delegate = self
        
        self.appIDLabel.text = "AppID: \(self.appID)"
        self.placementLabel.text = "placementID: \(self.placementID)"
        
        self.myCollectionViewInit()
    }
    
    
    private func myCollectionViewInit() {
        self.myCollectionView.collectionViewLayout = self.collectionViewFlowLayout
        self.myCollectionView.isScrollEnabled = true
        self.myCollectionView.showsHorizontalScrollIndicator = false
        self.myCollectionView.showsVerticalScrollIndicator = true
        self.myCollectionView.backgroundColor = .clear
        self.myCollectionView.clipsToBounds = true
        self.myCollectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCollectionViewCell")
        self.myCollectionView.isPagingEnabled = false // <- 한 페이지의 넓이를 조절 할 수 없기 때문에 scrollViewWillEndDragging을 사용하여 구현
        self.myCollectionView.contentInsetAdjustmentBehavior = .never // <- 내부적으로 safe area에 의해 가려지는 것을 방지하기 위해서 자동으로 inset조정해 주는 것을 비활성화
        self.myCollectionView.contentInset = Const.collectionViewContentInset // <-
        self.myCollectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.3) // <- 스크롤이 빠르게 되도록 (페이징 애니메이션같이 보이게하기 위함)
        self.myCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func adLoadBtnAction(_ sender: Any) {
        PointHomeADS().getADPlace(userKey: self.userKey,
                                  placementID: self.placementID,
                                  deviceADID: IDFA) {
            result in
            switch result {
            case .success(let item):
                print("item \(item)")
                DispatchQueue.main.async {
                    self.loadLabel.text = "PointHomeADS().getADplace(userKey: \(self.userKey) success"
                }
                if !item.ads.isEmpty{
                    DispatchQueue.main.async{
                        self.adItems = item.ads.map {
                            MyModel(
                                title: $0.title ?? "",
                                iconUrl: $0.iconUrl,
                                imageUrl: $0.imageUrl,
                                reward: $0.reward,
                                landingUrl: $0.landingUrl,
                                placementID: $0.placementID,
                                advertiseID: $0.advertiseID,
                                deviceID: self.uuid,
                                IDFA: self.IDFA
                            )
                        }
                        
                        self.myCollectionView.reloadData()
                        
                        print("self.adItems[0].placementID \(self.adItems[0].placementID)")
                        print("self.adItems[0].advertiseID \(self.adItems[0].advertiseID)")
                        
                        // 최초 로드시 Impression 호출.
                        PointHomeADS().postADSImpression(userKey: self.userKey,
                                                         placementID: self.adItems[0].placementID ?? "",
                                                         advertiseID: self.adItems[0].advertiseID ?? "",
                                                         deviceADID: self.IDFA) {
                            result in
                            DispatchQueue.main.async{
                                switch result {
                                case .success(let item):
                                    print("\(0)번째 postADSImpression success \(item)")
                                    self.impressionLabel.text = "\(0)번째 postADSImpression success \(item)"
                                case .failure(let error):
                                    print("\(0)번째 postADSImpression error \(error)")
                                    self.impressionLabel.text = "\(0)번째 postADSImpression error \(error)"
                                }
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async{
                        print("No ads found")
                        self.loadLabel.text = "PointHomeADS().getADplace(userKey: \(self.userKey) error"
                    }
                }
            case .failure(let error):
                print("error \(error)")
                DispatchQueue.main.async {
                    self.loadLabel.text = "PointHomeADS().getADplace(userKey: \(self.userKey) error"
                }
            }
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        // Create a data task to download the image data
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors and ensure there is image data
            guard let data = data, error == nil else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Create a UIImage from the data and set it on the main thread
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}

extension PHAdsViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Celld의 전체 너비
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        
        // 스크롤 뷰의 컨텐츠가 실제로 스크롤된 거리를 계산
        let scrolledOffestX = scrollView.contentOffset.x + scrollView.contentInset.left
        
        // 현재 index
        let nowIndex = round(scrolledOffestX / cellWidth)
        // 사용자가 슬라이드 후 움직이고 나서 index
        var index = round(scrolledOffestX / cellWidth)
        
        // 사용자의 x축 슬라이드 움직임
        if velocity.x > 0 {
            // 올림
            index = ceil(scrolledOffestX / cellWidth)
        }else if velocity.x < 0 {
            // 내림
            index = floor(scrolledOffestX / cellWidth)
        }
        
        print("[scroll] cellWidth \(cellWidth)")
        print("[scroll] scrolledOffestX \(scrolledOffestX) = \(scrollView.contentOffset.x) + \(scrollView.contentInset.left)")
        print("[scroll] nowIndex \(nowIndex) = \(scrolledOffestX) / \(cellWidth)")
        print("[scroll] index \(index)")
        print("[scroll] velocity.x \(velocity.x)")
        
        // index에 맞춰서 셀 이동 끝나고 셀을 중앙에 위치시킵니다.
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        // nowIndex != index -> 이동했을때
        // index >=0 && index <= adItems.count -1 -> 통신으로 받아온 item
        if nowIndex != index && (index >= 0 && index <= Double(adItems.count - 1)) {
            print("[scroll] impression on")
            // 유저가 캐로셀을 이동했을때마다 유저가 보고 있는 index의 광고 impression 호출합니다.
            // 대신 유저가 캐로셀을 움직이지 않거나 최대로 움직였을때 이상한 값이 불리지 않도록 예외처리했습니다.
            PointHomeADS().postADSImpression(userKey: self.userKey, placementID: self.adItems[Int(index)].placementID ?? "", advertiseID: self.adItems[Int(index)].advertiseID ?? "", deviceADID: self.IDFA) { result in
                DispatchQueue.main.async{
                    switch result {
                    case .success(let item):
                        print("\(Int(index)+1)번째 postADSImpression success \(item)")
                        self.impressionLabel.text = "\(Int(index)+1)번째 postADSImpression success \(item)"
                    case .failure(let error):
                        print("\(Int(index)+1)번째 postADSImpression error \(error)")
                        self.impressionLabel.text = "\(Int(index)+1)번째 postADSImpression error \(error)"
                    }
                }
            }
        }
    }
}
