//
//  PriceCalendarDirectCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 01.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class PriceCalendarDirectCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var directSwitch: UISwitch!

    private var action: ((UISwitch) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBackground(animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackground(animated: animated)
    }

    func setup(_ cellModel: PriceCalendarDirectCellModel, action: @escaping (UISwitch) -> Void) {
        infoLabel.text = cellModel.info
        directSwitch.isOn = cellModel.isOn
        self.action = action
    }

    @IBAction func directSwitchValueChanged(_ sender: UISwitch) {
        action?(sender)
    }
}

private extension PriceCalendarDirectCell {

    func updateBackground(animated: Bool) {
        let color = isSelected || isHighlighted ? JRColorScheme.itemsSelectedBackgroundColor() : JRColorScheme.itemsBackgroundColor()
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.containerView.backgroundColor = color
        }
    }
}
