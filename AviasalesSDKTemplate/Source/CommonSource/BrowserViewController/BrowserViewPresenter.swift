//
//  BrowserViewPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 29.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

@objc protocol BrowserViewPresenter {
    func handleLoad(view: BrowserViewProtocol)
    func handleClose()
    func handleStartNavigation()
    func handleCommit()
    func handleFinish()
    func handleFail(error: Error)
    func handleFailedURL()
    func handleError()
    func handleGoBack()
    func handleGoForward()
}
