//
//  CollectionViewController.swift
//  PointHomeSample
//
//  Created by 임재혁 on 11/22/24.
//

import UIKit
import AdCashFramework

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var pointHomeCollectionView: UICollectionView!
    
    let adItems = ["11adb04d-de43-45cf-9fb0-fc96f0dcc162",
                   "11adb04d-de43-45cf-9fb0-fc96f0dcc162",
                   "11adb04d-de43-45cf-9fb0-fc96f0dcc162"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.pointHomeCollectionView.dequeueReusableCell(withReuseIdentifier: "PointHomeCollectionViewCell", for: indexPath) as! PointHomeCollectionViewCell
        let adItem = adItems[indexPath.row]
        cell.prepare(rootVC: self, placementId: adItem)
        return cell
    }
    
    private enum Const {
        static let itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 300)
        static let itemSpacing = 0.0

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
        layout.itemSize = Const.itemSize // <- item 크기
        layout.minimumLineSpacing = Const.itemSpacing // <- item
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pointHomeCollectionView.dataSource = self
        self.pointHomeCollectionView.delegate = self
        
        myCollectionViewInit()
    }
    
    private func myCollectionViewInit() {
        self.pointHomeCollectionView.collectionViewLayout = self.collectionViewFlowLayout
        self.pointHomeCollectionView.isScrollEnabled = true
        self.pointHomeCollectionView.showsHorizontalScrollIndicator = false
        self.pointHomeCollectionView.showsVerticalScrollIndicator = true
        self.pointHomeCollectionView.backgroundColor = .clear
        self.pointHomeCollectionView.clipsToBounds = true
        self.pointHomeCollectionView.register(UINib(nibName: "PointHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PointHomeCollectionViewCell")
        self.pointHomeCollectionView.isPagingEnabled = false // <- 한 페이지의 넓이를 조절 할 수 없기 때문에 scrollViewWillEndDragging을 사용하여 구현
        self.pointHomeCollectionView.contentInsetAdjustmentBehavior = .never // <- 내부적으로 safe area에 의해 가려지는 것을 방지하기 위해서 자동으로 inset조정해 주는 것을 비활성화
        self.pointHomeCollectionView.contentInset = Const.collectionViewContentInset // <-
        self.pointHomeCollectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.3) // <- 스크롤이 빠르게 되도록 (페이징 애니메이션같이 보이게하기 위함)
        self.pointHomeCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
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
    }
}
