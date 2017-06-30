//
//  HLScrollView.swift
//  HotelLook
//
//  Created by Anton Chebotov on 03/03/15.
//  Copyright (c) 2015 Anton Chebotov. All rights reserved.
//

import UIKit

class HLScrollView: UIScrollView {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        let subview = hitTest(point, with: nil)

        switch subview {
        case is UISlider, is HLRangeSlider:
            return false

        default:
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }

}
