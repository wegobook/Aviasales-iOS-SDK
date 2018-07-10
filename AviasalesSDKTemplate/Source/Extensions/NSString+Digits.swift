//
//  NSString+Digits.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 31.05.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

extension NSString {

    private static let digits: [String : String] = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        var digits = [String : String]()
        Array(0...9).forEach { value in
            if let key = formatter.string(from: NSNumber(value: value)) {
                digits[key] = "\(value)"
            }
        }
        return digits
    }()

    @objc func arabicDigits() -> String {
        return (self as String).map { NSString.digits["\($0)"] ?? "\($0)" }.joined()
    }
}
