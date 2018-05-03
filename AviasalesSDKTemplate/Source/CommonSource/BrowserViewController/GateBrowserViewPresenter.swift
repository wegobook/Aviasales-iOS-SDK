//
//  GateBrowserViewPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 27.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

@objcMembers
class GateBrowserViewPresenter: NSObject {

    fileprivate weak var view: BrowserViewProtocol?

    fileprivate let proposal: JRSDKProposal
    fileprivate let purchasePerformer: AviasalesSDKPurchasePerformer
    fileprivate var request: URLRequest?

    init(ticketProposal: JRSDKProposal, searchID: String) {
        proposal = ticketProposal
        purchasePerformer = AviasalesSDKPurchasePerformer(proposal: ticketProposal, searchId: searchID)
        super.init()
    }
}

extension GateBrowserViewPresenter: BrowserViewPresenter {

    func handleLoad(view: BrowserViewProtocol) {
        self.view = view
        view.set(title: proposal.gate.label)
        view.updateControls()
        view.showLoading()
        purchasePerformer.perform(with: self)
    }

    func handleClose() {
        view?.stopLoading()
        view?.hideActivity()
        view?.dismiss()
    }

    func handleStartNavigation() {
        view?.showActivity()
    }

    func handleCommit() {
        view?.updateControls()
    }

    func handleFinish() {
        view?.hideLoading()
        view?.hideActivity()
    }

    func handleFail(error: Error) {
        view?.hideLoading()
        view?.hideActivity()
        if !error.isCancelledError {
            view?.showError(message: error.localizedDescription)
        }
    }

    func handleFailedURL() {
        if let request = request {
            view?.reload(request: request)
        }
    }

    func handleError() {
        view?.dismiss()
    }

    func handleGoBack() {
        view?.goBack()
    }

    func handleGoForward() {
        view?.goForward()
    }
}

extension GateBrowserViewPresenter: AviasalesSDKPurchasePerformerDelegate {

    public func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFinishWith URLRequest: URLRequest!, clickID: String!) {
        view?.load(request: URLRequest, scripts: [String]())
        self.request = URLRequest
    }

    func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFailWithError error: Error!) {
        view?.hideLoading()
        view?.showError(message: error.localizedDescription)
    }
}
