//
//  InfoScreenPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import Foundation

protocol InfoScreenViewProtocol: class {
    func set(title: String)
    func set(cellModels: [InfoScreenCellModelProtocol])
    func open(url: URL)
    func showCurrencyPicker()
    func sendEmail(address: String)
}

class InfoScreenPresenter {

    weak var view: InfoScreenViewProtocol?

    func attach(_ view: InfoScreenViewProtocol) {
        self.view = view
        view.set(title: NSLS("LOC_INFO"))
        view.set(cellModels: self.buildCellModels())
    }

    func rate() {
        guard let url = URL(string: ConfigManager.shared.itunesLink) else {
            return
        }
        view?.open(url: url)
    }

    func select(cellModel: InfoScreenCellModelProtocol) {
        switch cellModel.type {
        case .currency:
            view?.showCurrencyPicker()
        case .email:
            view?.sendEmail(address: ConfigManager.shared.feedbackEmail)
        case .external:
            openURL(from: cellModel as! InfoScreenExtrnalCellModel)
        case .about, .rate, .version:
            return
        }
    }

    func update() {
        view?.set(cellModels: self.buildCellModels())
    }

    private func openURL(from cellModel: InfoScreenExtrnalCellModel) {

        guard let link = cellModel.url, let url = URL(string: link), let scheme = url.scheme, scheme.contains("http") else {
            return
        }

        view?.open(url: url)
    }
}

private extension InfoScreenPresenter {

    func buildCellModels() -> [InfoScreenCellModelProtocol] {

        var cellModels = [InfoScreenCellModelProtocol]()

        let canRate = !ConfigManager.shared.itunesLink.isEmpty

        cellModels.append(buildAboutCellModel(separator: !canRate))

        if canRate {
            cellModels.append(buildRateCellModel())
        }

        cellModels.append(buildCurrencyCellModel())

        if ConfigManager.shared.feedbackEmail.contains("@") {
            cellModels.append(buildEmailCellModel())
        }

        if let externalLinks = ConfigManager.shared.externalLinks {
            cellModels.append(contentsOf: buildExternalCellModels(from: externalLinks))
        }

        cellModels.append(buildVersionCellModel())

        return cellModels
    }

    func buildAboutCellModel(separator: Bool) -> InfoScreenAboutCellModel {
        return InfoScreenAboutCellModel(icon: "AppIcon60x60", logo: appLogo(), name: appName(), description: appDescription(), separator: separator)
    }

    func appLogo() -> String? {
        return ConfigManager.shared.appLogo
    }

    func appName() -> String? {

        if let appName = ConfigManager.shared.appName {
            return appName
        }

        var result: String? = nil

        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            result = displayName
        } else if let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String {
            result = name
        }

        return result
    }

    func appDescription() -> String? {
        return ConfigManager.shared.appDescription
    }

    func buildRateCellModel() -> InfoScreenRateCellModel {
        return InfoScreenRateCellModel(name: NSLS("LOC_RATE_APP_TITLE"))
    }

    func buildCurrencyCellModel() -> InfoScreenDetailCellModel {
        return InfoScreenDetailCellModel(type: .currency, title: NSLS("CURRENCY"), subtitle: CurrencyManager.shared.currency.code)
    }

    func buildEmailCellModel() -> InfoScreenBasicCellModel {
        return InfoScreenBasicCellModel(type: .email, title: NSLS("HL_LOC_ABOUT_EMAIL_TITLE"))
    }

    func buildExternalCellModels(from externalLinks: [ExternalLink]) -> [InfoScreenCellModelProtocol] {
        return externalLinks.filter { !($0.name?.isEmpty ?? true) }.map { InfoScreenExtrnalCellModel(name: $0.name, url: $0.url) }
    }

    func buildVersionCellModel() -> InfoScreenVersionCellModel {
        return InfoScreenVersionCellModel(version: appVersion())
    }

    func appVersion() -> String? {

        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return nil
        }

        return NSLS("HL_LOC_ABOUT_VERSION_TITLE") + " " + version
    }
}
