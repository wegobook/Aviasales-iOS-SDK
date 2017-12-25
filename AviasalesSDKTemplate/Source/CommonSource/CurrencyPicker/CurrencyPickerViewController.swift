//
//  CurrencyPickerViewController.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 11.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class CurrencyPickerViewController: UIViewController {

    let presenter: CurrencyPickerPresenter

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var sectionModels = [CurrencyPickerSectionModel]()

    init(selection: @escaping () -> Void) {
        presenter = CurrencyPickerPresenter(selection: selection)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.attach(self)
    }

    // MARK: - Setup

    private func setup() {
        setupNavigationItem()
        setupSearchBar()
        setupTableView()
    }

    private func setupNavigationItem() {
        navigationItem.title = NSLS("HL_LOC_ABOUT_CURRENCY")
    }

    private func setupSearchBar() {
        searchBar.placeholder = NSLS("LOC_CURRENCY_SEARCH_PLACEHOLDER")
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.tintColor = JRColorScheme.darkTextColor()
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: CurrencyCell.identifier, bundle: nil), forCellReuseIdentifier: CurrencyCell.identifier)
    }

    // MARK: - Update

    fileprivate func updateVisibleCells() {

        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            return
        }

        for indexPath in indexPaths {
            let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as? CurrencyCell
            cell?.update(cellModel)
        }
    }

    fileprivate func updateCell(at indexPath: IndexPath) {
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? CurrencyCell
        cell?.update(cellModel)
    }
}

extension CurrencyPickerViewController: CurrencyPickerViewProtocol {

    func set(sectionModels: [CurrencyPickerSectionModel]) {
        self.sectionModels = sectionModels
        tableView.reloadData()
        tableView.contentOffset = .zero
    }

    func update(sectionModels: [CurrencyPickerSectionModel]) {
        self.sectionModels = sectionModels
        updateVisibleCells()
    }

    func showCurrencyAlert() {
        showAlert(title: NSLS("CHANGE_CURRENCY_ALERT_TITLE"), message: NSLS("CHANGE_CURRENCY_ALERT_DESCRIPTION"), cancelButtonTitle: NSLS("HL_LOC_ALERT_CLOSE_BUTTON"))
    }
}

extension CurrencyPickerViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        presenter.search(String())
        searchBar.resignFirstResponder()
    }
}

extension CurrencyPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.identifier, for: indexPath) as! CurrencyCell
        cell.setup(cellModel)
        return cell
    }
}

extension CurrencyPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.sectionFooterHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        presenter.select(cellModel)
    }
}
