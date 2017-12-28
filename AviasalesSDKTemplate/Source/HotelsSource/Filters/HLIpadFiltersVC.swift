//
//  HLIpadFiltersVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 10/05/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class HLIpadFiltersVC: HLFiltersVC {

    @IBOutlet private weak var dropButton: UIButton!
    @IBOutlet private weak var hotelsLeftLabel: UILabel!
    @IBOutlet private weak var hotelsLeftView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dropButton.setTitle(NSLS("HL_LOC_FILTER_DROP_BUTTON"), for: .normal)
        dropButton.setTitleColor(JRColorScheme.actionColor(), for: .normal)
        hotelsLeftView.layer.cornerRadius = 6
        hotelsLeftView.layer.shadowRadius = 2
        hotelsLeftView.layer.shadowOffset = CGSize.zero
        hotelsLeftView.layer.shadowColor = UIColor.black.cgColor
        hotelsLeftView.layer.shadowOpacity = 0.5

        var inset = tableView.contentInset
        inset.bottom += hotelsLeftView.frame.height
        tableView.contentInset = inset

        SeparatorView().attachToView(view, edge: .leading)
    }

    override func updateDropButtonState() {
        dropButton.isEnabled = filter!.canDropFilters()
    }

    override func updateHotelsCountLabel() {
        if let filter = filter {
            hotelsLeftLabel.text = StringUtils.filteredHotelsDescription(withFiltered: filter.filteredVariants.count, total: filter.allVariants.count)
        }
    }
}
