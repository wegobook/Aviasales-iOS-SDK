//
//  HLZoomablePhotoScrollView.swift
//  HotelLook
//
//  Created by Oleg on 04/02/16.
//
//

import UIKit

class HLZoomablePhotoScrollView: HLPhotoScrollView {

    // MARK: - Override methods

    override var reuseCellIdentifier: String {
        return "ZoomablePhotoScrollCollectionCell"
    }

    override func initialize() {
        super.initialize()

        self.collectionView.register(HLZoomablePhotoScrollCollectionCell.self, forCellWithReuseIdentifier: self.reuseCellIdentifier)
    }

}

extension HLZoomablePhotoScrollView {

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! HLZoomablePhotoScrollCollectionCell
        cell.zoomEnabled = true

        return cell
    }

}
