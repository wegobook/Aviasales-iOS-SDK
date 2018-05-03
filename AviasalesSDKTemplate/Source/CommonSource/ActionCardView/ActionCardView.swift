//
//  ActionCardView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 05.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

struct ActionCardViewModel {
    let title: String?
    let text: String?
    let button: String?
}

class ActionCardView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    var action: ((UIButton) -> Void)?

    func setup(_ viewModel: ActionCardViewModel) {
        titleLabel.text = viewModel.title
        textLabel.text = viewModel.text
        actionButton.setTitle(viewModel.button, for: .normal)
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        action?(sender)
    }
}
