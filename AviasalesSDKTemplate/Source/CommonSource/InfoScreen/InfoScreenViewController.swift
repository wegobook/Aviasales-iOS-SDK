//
//  InfoScreenViewController.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit
import SafariServices

class InfoScreenViewController: UIViewController, InfoScreenIconImageViewFiveTimesTapHandler {

    private let presenter = InfoScreenPresenter()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    private let sender = HLEmailSender()

    var cellModels = [InfoScreenCellModelProtocol]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.attach(self)
    }

    // MARK: - Setup

    func setupViewController() {
        automaticallyAdjustsScrollViewInsets = false
        setupTableView()
        setupUI()
    }

    func setupTableView() {
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.frame.height ?? 0, right: 0)
    }

    func setupUI() {
        view.backgroundColor = JRColorScheme.mainBackgroundColor()
        containerView.layer.cornerRadius = 6
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem()
    }

    // MARK: - Navigation

    func showCurrencyPickerViewController() {
        let currencyPickerViewController = CurrencyPickerViewController { [weak self] in
            self?.presenter.update()
        }
        pushOrPresentBasedOnDeviceType(viewController: currencyPickerViewController, animated: true)
    }

    func openEmailSender(address: String) {
        sender.sendFeedbackEmail(to: address)
        present(sender.mailer, animated: true, completion: nil)
    }
}

private extension InfoScreenViewController {

    func buildAboutCell(cellModel: InfoScreenAboutCellModel) -> InfoScreenAboutCell {
        guard let cell = InfoScreenAboutCell.loadFromNib() else {
            fatalError("InfoScreenAboutCell has not been loaded")
        }
        cell.setup(cellModel: cellModel as InfoScreenAboutCellProtocol)
        let left: CGFloat = cellModel.separator ? tableView.separatorInset.left : view.bounds.width
        cell.separatorInset = UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0)
        cell.iconImageViewFiveTimesTapAction = { [weak self] in
            self?.handleFiveTimesTap()
        }
        return cell
    }

    func buildRateCell(cellModel: InfoScreenRateCellModel) -> InfoScreenRateCell {
        guard let cell = InfoScreenRateCell.loadFromNib() else {
            fatalError("InfoScreenRateCell has not been loaded")
        }
        cell.setup(cellModel: cellModel as InfoScreenRateCellProtocol) { [weak self] (_) in
            self?.presenter.rate()
        }
        return cell
    }

    func buildDetailCell(cellModel: InfoScreenDetailCellModel) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = cellModel.title
        cell.textLabel?.textColor = JRColorScheme.darkTextColor()
        cell.detailTextLabel?.text = cellModel.subtitle
        cell.detailTextLabel?.textColor = JRColorScheme.mainColor()
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func buildBasicCell(cellModel: InfoScreenBasicCellModel) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = cellModel.title
        cell.textLabel?.textColor = JRColorScheme.darkTextColor()
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func buildExternalCell(cellModel: InfoScreenExtrnalCellModel) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = cellModel.name
        cell.textLabel?.textColor = JRColorScheme.darkTextColor()
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func buildVersionCell(cellModel: InfoScreenVersionCellModel) -> InfoScreenVersionCell {
        guard let cell = InfoScreenVersionCell.loadFromNib() else {
            fatalError("InfoScreenVersionCell has not been loaded")
        }
        cell.setup(cellModel: cellModel as InfoScreenVersionCellProtocol)
        cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
        return cell
    }
}

extension InfoScreenViewController: InfoScreenViewProtocol {

    func set(title: String) {
        navigationItem.title = title
    }

    func set(cellModels: [InfoScreenCellModelProtocol]) {
        self.cellModels = cellModels
        tableView.reloadData()
    }

    func open(url: URL) {
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    func showCurrencyPicker() {
        showCurrencyPickerViewController()
    }

    func sendEmail(address: String) {
        if HLEmailSender.canSendEmail() {
            openEmailSender(address: address)
        } else {
            HLEmailSender.showUnavailableAlert(in: self)
        }
    }
}

extension InfoScreenViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.type {
        case .about:
            return buildAboutCell(cellModel: cellModel as! InfoScreenAboutCellModel)
        case .rate:
            return buildRateCell(cellModel: cellModel as! InfoScreenRateCellModel)
        case .currency:
            return buildDetailCell(cellModel: cellModel as! InfoScreenDetailCellModel)
        case .email:
            return buildBasicCell(cellModel: cellModel as! InfoScreenBasicCellModel)
        case .external:
            return buildExternalCell(cellModel: cellModel as! InfoScreenExtrnalCellModel)
        case .version:
            return buildVersionCell(cellModel: cellModel as! InfoScreenVersionCellModel)
        }
    }
}

extension InfoScreenViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = cellModels[indexPath.row]
        presenter.select(cellModel: cellModel)
    }
}
