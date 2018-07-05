//
//  BrowserViewController.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 26.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit
import WebKit

@objc protocol BrowserViewProtocol {
    func set(title: String?)
    func showLoading()
    func hideLoading()
    func showActivity()
    func hideActivity()
    func load(request: URLRequest, scripts: [String])
    func reload(request: URLRequest)
    func stopLoading()
    func dismiss()
    func updateControls()
    func goBack()
    func goForward()
    func showError(message: String)
}

class BrowserViewController: UIViewController {

    private struct Keys {
        static let url = "URL"
    }

    private let presenter: BrowserViewPresenter

    private lazy var closeBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filtersCrossButton"),
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(closeBarButtonItemTapped(_:)))

    private lazy var goBackBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "browser_back_icon").imageFlippedForRightToLeftLayoutDirection(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(goBackBarButtonItemTapped(_:)))

    private lazy var goForwardBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "browser_forward_icon").imageFlippedForRightToLeftLayoutDirection(),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(goForwardBarButtonItemTapped(_:)))

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var loadingView: LoadingView!

    private var webView: WKWebView?

    @objc required init(presenter: BrowserViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.handleLoad(view: self)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Keys.url, webView?.url == nil {
            presenter.handleFailedURL()
        }
    }

    deinit {
        webView?.removeObserver(self, forKeyPath: Keys.url)
    }

    // MARK: - Setup

    func setup() {
        setupNavigationItems()
    }

    func setupNavigationItems() {
        navigationItem.rightBarButtonItems =  [goForwardBarButtonItem, goBackBarButtonItem]
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }

    // MARK: - Error

    func showErrorAlert(message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: NSLS("JR_ERROR_TITLE"), message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLS("JR_OK_BUTTON"), style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: - Actions

    @objc func closeBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presenter.handleClose()
    }

    @objc func goBackBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presenter.handleGoBack()
    }

    @objc func goForwardBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presenter.handleGoForward()
    }
}

private extension BrowserViewController {

    func webView(_ scripts: [String]) -> WKWebView {
        let webView = WKWebView(scripts: scripts)
        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(JRConstraintsMakeScaleToFill(webView, webViewContainer))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.addObserver(self, forKeyPath: Keys.url, options: [.new, .old], context: nil)
        return webView
    }
}

extension BrowserViewController: BrowserViewProtocol {

    func set(title: String?) {
        navigationItem.title = title
    }

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func load(request: URLRequest, scripts: [String]) {
        webView = webView(scripts)
        webView?.load(request)
    }

    func reload(request: URLRequest) {
        webView?.load(request)
    }

    func stopLoading() {
        webView?.stopLoading()
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func updateControls() {
        goBackBarButtonItem.isEnabled = webView?.canGoBack ?? false
        goForwardBarButtonItem.isEnabled = webView?.canGoForward ?? false
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func showError(message: String) {
        showErrorAlert(message: message) { [weak self] in
            self?.presenter.handleError()
        }
    }
}

extension BrowserViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension BrowserViewController: WKNavigationDelegate {

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
