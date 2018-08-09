//
//  AdContainerView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 01.08.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class AdContainerView: UIView {

    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = JRColorScheme.mainBackgroundColor()
        containerView.layer.cornerRadius = 6
    }
}
