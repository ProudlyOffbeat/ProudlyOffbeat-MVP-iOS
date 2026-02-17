//
//  CarouselFlowLayout.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class CarouselFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Override

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: 0,
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )

        guard let attributes = layoutAttributesForElements(in: targetRect) else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        // 화면 중앙 x 좌표
        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2

        // 가장 중앙에 가까운 셀 찾기
        let closest = attributes.min(by: {
            abs($0.center.x - centerX) < abs($1.center.x - centerX)
        })

        guard let targetAttributes = closest else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        // 해당 셀이 중앙에 오도록 offset 계산
        let offsetX = targetAttributes.center.x - collectionView.bounds.width / 2

        return CGPoint(x: offsetX, y: proposedContentOffset.y)
    }
}
