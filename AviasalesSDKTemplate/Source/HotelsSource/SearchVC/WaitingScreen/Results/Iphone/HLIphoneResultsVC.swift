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

    override func viewDidLoad() {
        super.viewDidLoad()

        sortButton.backgroundColor = JRColorScheme.actionColor()
        sortButton.setTitleColor(.white, for: .normal)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonsBottomConstraint.constant = bottomLayoutGuide.length
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
