//
//  PurpleColorScheme.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

@objc class PurpleColorScheme: NSObject, ColorScheme {

    func tintColor() -> UIColor {
        return navigationBarBackgroundColor()
    }

    func searchFormTintColor() -> UIColor {
        return navigationBarItemColor()
    }

    func navigationBarBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.6117647059, green: 0.4235294118, blue: 0.7450980392, alpha: 1)
    }

    func navigationBarItemColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func searchFormBackgroundColor() -> UIColor {
        return navigationBarBackgroundColor()
    }

    func searchFormTextColor() -> UIColor {
        return navigationBarItemColor()
    }

    func searchFormSeparatorColor() -> UIColor {
        return navigationBarItemColor()
    }

    func mainButtonBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    }

    func mainButtonTitleColor() -> UIColor {
        return navigationBarItemColor()
    }
}
