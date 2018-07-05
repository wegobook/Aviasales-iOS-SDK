//
//  UIView+RTL.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 11.05.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

extension UIView {

    var isRTL: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }

    @objc func transformRTL() {
        if isRTL {
            transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }

}
