//
//  CustomColorScheme.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

@objc class CustomColorScheme: NSObject, ColorScheme {

    func tintColor() -> UIColor {
        return #colorLiteral(red: 0.695192039, green: 0.8594229817, blue: 0.04666034132, alpha: 1)
    }

    func searchFormTintColor() -> UIColor {
        return #colorLiteral(red: 0.695192039, green: 0.8594229817, blue: 0.04666034132, alpha: 1)
    }

    func navigationBarBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.695192039, green: 0.8594229817, blue: 0.04666034132, alpha: 1)
    }

    func navigationBarItemColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func searchFormBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 0.8507557776, alpha: 1)
    }

    func searchFormTextColor() -> UIColor {
        return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }

    func searchFormSeparatorColor() -> UIColor {
        return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }

    func mainButtonBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    }

    func mainButtonTitleColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
