//
//  BlackColorScheme.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

@objc class BlackColorScheme: NSObject, ColorScheme {

    func tintColor() -> UIColor {
        return navigationBarBackgroundColor()
    }

    func searchFormTintColor() -> UIColor {
        return navigationBarItemColor()
    }

    func navigationBarBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.2588235294, green: 0.2666666667, blue: 0.2784313725, alpha: 1)
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
        return #colorLiteral(red: 1, green: 0.6235294118, blue: 0, alpha: 1)
    }

    func mainButtonTitleColor() -> UIColor {
        return navigationBarItemColor()
    }
}
