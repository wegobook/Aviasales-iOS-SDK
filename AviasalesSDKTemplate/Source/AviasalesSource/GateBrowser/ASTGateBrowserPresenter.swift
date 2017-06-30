//
//  ASTGateBrowserPresenter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol ASTGateBrowserViewProtocol: NSObjectProtocol {

    func showLoading()
    func hideLoading()
    func showActivity()
    func hideActivity()
    func update(request: URLRequest)
    func stopLoading()
    func dismiss()
    func updateControls()
    func goBack()
    func goForward()
    func showError(title: String, message: String, cancel: String)
}

class ASTGateBrowserPresenter: NSObject {

    fileprivate weak var view: ASTGateBrowserViewProtocol?

    let purchasePerformer: AviasalesSDKPurchasePerformer

    init(ticketProposal: JRSDKProposal, searchID: String) {
        purchasePerformer = AviasalesSDKPurchasePerformer(proposal: ticketProposal, searchId: searchID)
        super.init()
    }

    func handleLoad(view: ASTGateBrowserViewProtocol) {
        self.view = view
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
            makeViewShowError(error: error)
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

private extension ASTGateBrowserPresenter {

    func makeViewShowError(error: Error) {
        view?.showError(title: NSLS("JR_ERROR_TITLE"), message: error.localizedDescription, cancel: NSLS("JR_OK_BUTTON"))
    }
}

extension ASTGateBrowserPresenter: AviasalesSDKPurchasePerformerDelegate {

    func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFinishWith URLRequest: URLRequest!) {
        view?.update(request: URLRequest)
    }

    func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFailWithError error: Error!) {
        view?.hideLoading()
        makeViewShowError(error: error)
    }
}
