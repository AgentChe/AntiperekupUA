//
//  ReportCarouselFlowLayout.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import UIKit

final class ReportCarouselFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 8.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        
        let width = collectionView.bounds.width - collectionView.contentInset.left - minimumLineSpacing
        
        itemSize = CGSize(width: width, height: width * 9/16)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            guard let collectionView = collectionView else { return proposedContentOffset }
        
        let width = itemSize.width + minimumLineSpacing
        var offset = proposedContentOffset.x + collectionView.contentInset.left
        
        if velocity.x > 0 {
          offset = width * ceil(offset / width)
        } else if velocity.x == 0 {
          offset = width * round(offset / width)
        } else if velocity.x < 0 {
          offset = width * floor(offset / width)
        }
        return CGPoint(x: offset - collectionView.contentInset.left, y: 0)
    }
}
