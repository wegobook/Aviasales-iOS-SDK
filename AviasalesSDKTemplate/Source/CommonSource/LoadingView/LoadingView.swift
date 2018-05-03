//
//  LoadingView.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 22.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    @IBOutlet var view: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)?.first as! UIView
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(JRConstraintsMakeScaleToFill(self, view))
    }
}
