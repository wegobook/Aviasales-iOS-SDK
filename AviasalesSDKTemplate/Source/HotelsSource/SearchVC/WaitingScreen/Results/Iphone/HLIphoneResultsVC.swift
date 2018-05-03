//
//  HLIphoneResultsVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 09/03/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class HLIphoneResultsVC: HLCommonResultsVC {

    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!

    var sortBottomDrawer: BottomDrawer?

    private let collectionViewBottomInset: CGFloat = 70

    override func viewDidLoad() {
        super.viewDidLoad()

        sortButton.backgroundColor = JRColorScheme.actionColor()
        sortButton.setTitleColor(.white, for: .normal)

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonsBottomConstraint.constant = bottomLayoutGuide.length
        collectionView.contentInset.bottom = collectionViewBottomInset + bottomLayoutGuide.length
        collectionView.scrollIndicatorInsets.bottom = bottomLayoutGuide.length
    }

    override func updateContentWithVariants(_ variants: [HLResultVariant], filteredVariants: [HLResultVariant]) {
        if let drawer = sortBottomDrawer {
            drawer.dismissDrawer()
        }
        super.updateContentWithVariants(variants, filteredVariants: filteredVariants)
    }

    override func presentSortVC(_ sortVC: HLSortVC, animated: Bool) {
        super.presentSortVC(sortVC, animated: animated)

        navigationController?.pushViewController(sortVC, animated: true)
    }

    // MARK: - HLPlaceholderViewDelegate Methods

    func moveToNewSearch() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
