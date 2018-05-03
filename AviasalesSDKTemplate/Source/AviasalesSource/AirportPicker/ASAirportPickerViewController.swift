//
//  ASAirportPickerViewController.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 30.06.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

@objc enum ASAirportPickerType: Int {
    case origin
    case destination
}

@objcMembers
class ASAirportPickerViewController: UIViewController {

    let presenter: ASAirportPickerPresenter

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var sectionModels = [ASAirportPickerSectionViewModel]()

    // MARK: - Initialization

    init(type: ASAirportPickerType, selection: @escaping (JRSDKAirport) -> Void) {
        presenter = ASAirportPickerPresenter(type: type, selection: selection)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.attach(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }

    // MARK: - Setup

    func setupViewController() {
        setupTableView()
        setupSearchBar()
    }

    func setupTableView() {
        tableView.register(UINib(nibName:ASAirportPickerInfoCell.identifier, bundle: nil), forCellReuseIdentifier: ASAirportPickerInfoCell.identifier)
        tableView.register(UINib(nibName:ASAirportPickerDataCell.identifier, bundle: nil), forCellReuseIdentifier: ASAirportPickerDataCell.identifier)
    }

    func setupSearchBar() {
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.tintColor = JRColorScheme.darkTextColor()
    }
}

extension ASAirportPickerViewController: ASAirportPickerViewProtocol {

    func set(title: String) {
        navigationItem.title = title
    }

    func set(placeholder: String) {
        searchBar.placeholder = placeholder
    }

    func set(sectionModels: [ASAirportPickerSectionViewModel]) {
        self.sectionModels = sectionModels
        tableView.reloadData()
    }

    func popOrDismiss() {
        popOrDismissBasedOnDeviceType(animated: true)
    }
}

extension ASAirportPickerViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.set(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        presenter.set(searchText: String())
        searchBar.resignFirstResponder()
    }
}

extension ASAirportPickerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        switch cellModel.type {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: ASAirportPickerInfoCell.identifier, for: indexPath) as! ASAirportPickerInfoCell
            cell.setup(cellModel: cellModel as! ASAirportPickerInfoCellProtocol)
            return cell
        case .data:
            let cell = tableView.dequeueReusableCell(withIdentifier: ASAirportPickerDataCell.identifier, for: indexPath) as! ASAirportPickerDataCell
            cell.setup(cellModel: cellModel as! ASAirportPickerDataCellProtocol)
            return cell
        }
    }
}

extension ASAirportPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = sectionModels[section]
        let sectionView = ASAirportPickerSectionView.loadFromNib()
        sectionView?.setup(sectionModel: sectionModel as ASAirportPickerSectionViewProtocol)
        return sectionView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionModel = sectionModels[section]
        return sectionModel.name == nil ? CGFloat.leastNormalMagnitude : tableView.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = sectionModels[indexPath.section].cellModels[indexPath.row]
        presenter.select(cellModel: cellModel)
    }
}
