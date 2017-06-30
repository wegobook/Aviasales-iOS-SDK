//
//  BottomDrawer+Objc.swift
//  Aviasales iOS Apps
//
//  Created by Denis Chaschin on 26.02.16.
//  Copyright © 2016 aviasales. All rights reserved.
//

import Foundation

extension BottomDrawer {
    @objc var actionButtonHeight: CGFloat {
        set {
            actionButtonStyle.height = newValue
        }
        get {
            return actionButtonStyle.height
        }
    }

    @objc var actionButtonBackgroundColor: UIColor {
        set {
            actionButtonStyle.backgroundColor = newValue
        }
        get {
            return actionButtonStyle.backgroundColor
        }
    }

    @objc var actionButtonSelectedBackgroundColor: UIColor {
        set {
            actionButtonStyle.selectedBackgroundColor = newValue
        }
        get {
            return actionButtonStyle.selectedBackgroundColor
        }
    }

    @objc var actionButtonTitleAttributes: [String: AnyObject] {
        set {
            actionButtonStyle.titleAttributes = newValue
        }
        get {
            return actionButtonStyle.titleAttributes
        }
    }
    
    //MARK: shared
    @objc static var actionButtonHeight: CGFloat {
        set {
            defaultActionButtonStyle.height = newValue
        }
        get {
            return defaultActionButtonStyle.height
        }
    }

    @objc static var actionButtonBackgroundColor: UIColor {
        set {
            defaultActionButtonStyle.backgroundColor = newValue
        }
        get {
            return defaultActionButtonStyle.backgroundColor
        }
    }

    @objc static var actionButtonSelectedBackgroundColor: UIColor {
        set {
            defaultActionButtonStyle.selectedBackgroundColor = newValue
        }
        get {
            return defaultActionButtonStyle.selectedBackgroundColor
        }
    }

    @objc static var actionButtonTitleAttributes: [String: AnyObject] {
        set {
            defaultActionButtonStyle.titleAttributes = newValue
        }
        get {
            return defaultActionButtonStyle.titleAttributes
        }
    }
}