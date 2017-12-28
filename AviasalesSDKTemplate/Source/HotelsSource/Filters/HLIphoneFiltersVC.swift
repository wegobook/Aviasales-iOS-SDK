//
//  ASTIphoneFiltersVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 10/05/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class HLIphoneFiltersVC: HLFiltersVC {

    @IBOutlet weak var applyButtonBottomLayoutConstraint: NSLayoutConstraint!

    private var dropItem: UIBarButtonItem!
    private let navBarView = FiltersNavBarView()

    override func viewDidLoad() {
        addDropButton()

        super.viewDidLoad()

        addHotelsLeftView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyButtonBottomLayoutConstraint.constant = bottomLayoutGuide.length + 10;
    }

    private func addDropButton() {
        let dropTitle = NSLS("HL_LOC_FILTER_DROP_BUTTON")
        let sel = #selector(HLPlaceholderViewDelegate.dropFilters)
        dropItem = UIBarButtonItem(title:dropTitle, style:.plain, target:self, action:sel)
        if iPad() {
            navigationItem.leftBarButtonItem = dropItem
        } else {
            navigationItem.rightBarButtonItem = dropItem
        }

    }

    private func addHotelsLeftView() {
        navBarView.setupConstraints()
        let limits = CGSize(width: 200.0, height: 35.0)
        if let filter = filter {
            let maxHotelsCount = filter.allVariants.count
            navBarView.hotelsLeft(maxHotelsCount, outOf: maxHotelsCount)
        }
        let size = navBarView.systemLayoutSizeFitting(limits)
        navBarView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10, height: size.height)
        navigationItem.titleView = navBarView

        updateHotelsCountLabel()
    }

    override func updateHotelsCountLabel() {
        if let filter = filter {
            navBarView.hotelsLeft(filter.filteredVariants.count, outOf: filter.allVariants.count)
        }
    }

    override func updateDropButtonState() {
        dropItem.isEnabled = filter!.canDropFilters()
    }

}
