//
//  BookBrowserViewPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 27.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

class BookBrowserViewPresenter {

    fileprivate weak var view: BrowserViewProtocol?

    fileprivate let room: HDKRoom
    fileprivate var request: URLRequest?

    init(room: HDKRoom) {
        self.room = room
    }
}

extension BookBrowserViewPresenter: BrowserViewPresenter {

    func handleLoad(view: BrowserViewProtocol) {
        self.view = view
        view.set(title: room.gate.name)
        view.updateControls()
        loadURL()
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

private extension BookBrowserViewPresenter {

    func loadURL() {

        guard let url = room.deeplink  else {
            view?.showError(message: NSLS("BROWSER_LOAD_ERROR"))
            return
        }

        view?.showLoading()

        ServiceLocator.shared.api.deeplinkInfo(url: url).promise()
            .then { [weak self] deeplinkInfo in
                self?.deeplinkLoaderSuccess(withUrl: deeplinkInfo.url, scripts: deeplinkInfo.scripts)
            }
            .catch { [weak self] error in
                self?.deeplinkLoaderFailedWithError(error)
        }
    }

    func deeplinkLoaderSuccess(withUrl urlStr: String!, scripts: [String]!) {
        guard let url = URL(string: urlStr) else {
            view?.showError(message: NSLS("BROWSER_LOAD_ERROR"))
            return
        }
        let request = URLRequest(url: url)
        view?.load(request: request, scripts: scripts)
        self.request = request
    }

    func deeplinkLoaderFailedWithError(_ error: Error) {
        view?.hideLoading()
        view?.showError(message: error.localizedDescription)
    }
}
