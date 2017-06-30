//
//  ColorSchemeConfigurator.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

@objc protocol ColorScheme: NSObjectProtocol {

    func tintColor() -> UIColor
    func searchFormTintColor() -> UIColor
    func navigationBarBackgroundColor() -> UIColor
    func navigationBarItemColor() -> UIColor
    func searchFormBackgroundColor() -> UIColor
    func searchFormTextColor() -> UIColor
    func searchFormSeparatorColor() -> UIColor
    func mainButtonBackgroundColor() -> UIColor
    func mainButtonTitleColor() -> UIColor
}

@objc class ColorSchemeConfigurator: NSObject {

    static let shared = ColorSchemeConfigurator()

    var currentColorScheme: ColorScheme = BlueColorScheme()
}
