//
//  ASTGateBrowserViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit
import WebKit

class ASTGateBrowserViewController: UIViewController {

    let presenter: ASTGateBrowserPresenter

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var loadingView: UIView!

    let webView = WKWebView()

    weak var goBackBarButtonItem: UIBarButtonItem?
    weak var goForwardBarButtonItem: UIBarButtonItem?

    init(ticketProposal: JRSDKProposal, searchID: String) {
        presenter = ASTGateBrowserPresenter(ticketProposal: ticketProposal, searchID: searchID)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.handleLoad(view: self)
    }

    // MARK: - Setup

    func setupViewController() {
        setupNavigationItems()
        setupWebView()
    }

    func setupNavigationItems() {
        navigationItem.title = NSLS("JR_BROWSER_TITLE")

        let goBackBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "browser_back_icon"), style: .plain, target: self, action: #selector(goBack(sender:)))
        let goForwardBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "browser_forward_icon"), style: .plain, target: self, action: #selector(goForward(sender:)))

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filtersCrossButton"), style: .plain, target: self, action: #selector(close(sender:)))
        navigationItem.rightBarButtonItems = [goForwardBarButtonItem, goBackBarButtonItem]

        self.goBackBarButtonItem = goBackBarButtonItem
        self.goForwardBarButtonItem = goForwardBarButtonItem
    }

    func setupWebView() {
        webViewContainer.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(JRConstraintsMakeScaleToFill(webView, webViewContainer))

        webView.navigationDelegate = self
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

    // MARK: - Actions

    func close(sender: UIBarButtonItem) {
        presenter.handleClose()
    }

    func goBack(sender: UIBarButtonItem) {
        presenter.handleGoBack()
    }

    func goForward(sender: UIBarButtonItem) {
        presenter.handleGoForward()
    }
}

extension ASTGateBrowserViewController: ASTGateBrowserViewProtocol {

    func showLoading() {
        loadingView.isHidden = false
    }

    func hideLoading() {
        loadingView.isHidden = true
    }

    func showActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func hideActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func update(request: URLRequest) {
        webView.load(request)
    }

    func stopLoading() {
        webView.stopLoading()
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func updateControls() {
        goBackBarButtonItem?.isEnabled = webView.canGoBack
        goForwardBarButtonItem?.isEnabled = webView.canGoForward
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func showError(title: String, message: String, cancel: String) {
        showErrorAlert(title: title, message: message, cancel: cancel) { [weak self] in
            self?.presenter.handleError()
        }
    }
}

extension ASTGateBrowserViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        presenter.handleStartNavigation()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        presenter.handleCommit()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        presenter.handleFinish()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        presenter.handleFail(error: error)
    }
}
