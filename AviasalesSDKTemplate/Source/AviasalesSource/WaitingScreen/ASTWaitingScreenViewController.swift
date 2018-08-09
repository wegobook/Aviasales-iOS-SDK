//
//  ASTWaitingScreenViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit
import Appodeal

@objcMembers
class ASTWaitingScreenViewController: UIViewController {

    let presenter: ASTWaitingScreenPresenter

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var planeScene: ASTWaitingScreenPlaneSceneView!
    @IBOutlet weak var infoLabel: UILabel!

    init(searchInfo: JRSDKSearchInfo) {
        presenter = ASTWaitingScreenPresenter(searchInfo: searchInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        presenter.handleUnload()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.handleLoad(view: self)
    }

    // MARK: - Setup

    func setupViewController() {
        view.backgroundColor = JRColorScheme.mainBackgroundColor()
        progressView.backgroundColor = JRColorScheme.mainBackgroundColor()
        progressView.progressColor = JRColorScheme.actionColor()
        progressView.transformRTL()
        Appodeal.setInterstitialDelegate(self)
    }

    // MARK: - Update

    func updateInfoLabel(text: String, range: NSRange) {
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: JRColorScheme.mainColor(), range: range)
        infoLabel.attributedText = attributedText
    }

    // MARK: - Error

    func showErrorAlert(title: String, message: String, cancel: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancel, style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: - Navigation

    func showSearchResultsViewController(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo) {

        let viewController: UIViewController
        if iPad() {
            viewController = ASTSearchResultsSceneViewController(searchResult: searchResult, searchInfo: searchInfo)
        } else {
            viewController = JRSearchResultsVC(searchInfo: searchInfo, response: searchResult)
        }

        navigationController?.replaceTopViewController(with: viewController)
    }
}

extension ASTWaitingScreenViewController: AppodealInterstitialDelegate {

    func interstitialWillPresent() {
        presenter.handleShowAdvertisement()
    }

    func interstitialDidDismiss() {
        presenter.handleHideAdvertisement()
    }
}

extension ASTWaitingScreenViewController: ASTWaitingScreenViewProtocol {

    func startAnimating() {
        planeScene.startAnimating()
    }

    func animateProgress(duration: TimeInterval) {
        progressView.animateProgress(duration: duration)
    }

    func update(title: String) {
        navigationItem.title = title
    }

    func updateInfo(text: String, range: NSRange) {
        updateInfoLabel(text: text, range: range)
    }

    func showAdvertisement() {
        Appodeal.showAd(.interstitial, rootViewController: self.navigationController ?? self)
    }

    func showSearchResults(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo) {
        showSearchResultsViewController(searchResult: searchResult, searchInfo: searchInfo)
    }

    func showError(title: String, message: String, cancel: String) {
        showErrorAlert(title: title, message: message, cancel: cancel) { [weak self] in
            self?.presenter.handleError()
        }
    }

    func pop() {
        self.navigationController?.popViewController(animated: true)
    }
}
