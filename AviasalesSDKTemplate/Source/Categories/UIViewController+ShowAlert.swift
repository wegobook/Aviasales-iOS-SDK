//
//  UIViewController+ShowAlert.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 22/03/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import Foundation

@objc public extension UIViewController {

    func showAlert(title: String?, message: String?, cancelButtonTitle: String) {
        let alert = createAlert(title: title, message: message, cancelButtonTitle: cancelButtonTitle)
        present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(message: String?) {
        showAlert(title: NSLS("JR_ERROR_TITLE"), message: message, cancelButtonTitle: NSLS("JR_OK_BUTTON"))
    }

    func createAlert(title: String?, message: String?, cancelButtonTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        alert.addAction(action)

        return alert
    }

    func createErrorAlert(message: String) -> UIAlertController {
        return createAlert(title: nil, message: message, cancelButtonTitle: NSLS("JR_OK_BUTTON"))
    }

}
