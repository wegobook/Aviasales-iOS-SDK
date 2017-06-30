//
//  UIViewController+Navigation.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

extension UIViewController {

    func pushOrPresentBasedOnDeviceType(viewController: UIViewController, animated: Bool) {
        if iPhone() {
            navigationController?.pushViewController(viewController, animated: animated)
        } else {
            let navigationController = JRNavigationController(rootViewController: viewController)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: animated, completion: nil)
        }
    }

    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    func popOrDismissBasedOnDeviceType(animated: Bool) {
        if iPhone() {
            navigationController?.popViewController(animated: animated)
        } else {
            navigationController?.dismiss(animated: animated, completion: nil)
        }
    }
}
