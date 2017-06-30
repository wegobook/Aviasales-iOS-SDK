//
//  UIViewController+BottomDrawer.swift
//  Aviasales iOS Apps
//
//  Created by Denis Chaschin on 13.08.15.
//  Copyright © 2015 aviasales. All rights reserved.
//

import Foundation

public extension UIViewController {
    var bottomDrawer: BottomDrawer? {
        if let res = self as? BottomDrawer {
            return res
        }
        return self.parent?.bottomDrawer
    }
}
