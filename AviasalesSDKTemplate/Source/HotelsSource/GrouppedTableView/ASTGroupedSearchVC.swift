//
//  ASTGroupedSearchVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 16/03/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

@objcMembers
class ASTGroupedSearchVC: ASTBaseSearchTableVC, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, HLCustomPointSelectionDelegate {

    var searchInfo: HLSearchInfo?
    var searchController: UISearchController!
    var resultsTableController = ASTSearchResultsVC(style: .grouped)
    var initialCustomPointSelectionLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialCustomPointSelectionLocation = searchInfo?.searchLocation() ?? CLLocation()

        tableView.backgroundColor = JRColorScheme.mainBackgroundColor()

        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        searchController.delegate = self
        searchController.searchBar.delegate = self

        resultsTableController.tableView.delegate = self
        resultsTableController.tableView.dataSource = self

        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true

        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem()
    }

    func resetTableContent() {
        sections = []
    }

    func locationRequestItem() -> GroupedTableItem {
        return LocationRequestItem(title: NSLS("HL_LOC_FILTERS_GIVE_LOCATION_ACCESS"), action: { [weak self] in
            self?.requestUserLocation()
            }, icon: UIImage(named: "locateMeSmall"))
    }

    func userLocationItem() -> GroupedTableItem {
        return GroupedTableItem(title: NSLS("HL_LOC_FILTERS_POINT_MY_LOCATION_TEXT"), action: { [weak self] in
            self?.userLocationSelected()
            }, icon: UIImage(named: "locateMeSmall"))
    }

    func customLocationPointItem() -> GroupedTableItem {
        return GroupedTableItem(title: NSLS("HL_LOC_POINT_ON_MAP_TEXT"), action: { [weak self] in
            self?.moveToCustomPointSelection()
            }, icon: UIImage(named: "pointOnMapIcon"))
    }

    func moveToCustomPointSelection() {
        let mapPointVC = HLCustomPointSelectionVC(nibName: "HLCustomPointSelectionVC", bundle: nil)
        mapPointVC.delegate = self
        mapPointVC.initialSearchInfoLocation = initialCustomPointSelectionLocation
        navigationController?.pushViewController(mapPointVC, animated: true)
    }

    func requestUserLocation() {
        registerForCurrentCityNotifications()
        HLLocationManager.shared().requestUserLocation(withLocationDestination: nil)
    }

    func userLocationSelected() {
        // Override in subclass
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        resultsTableController.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goBack()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HLGroupedTableHeaderView") as! HLGroupedTableHeaderView
        if tableView == self.tableView {
            header.title = sections[section].title
        } else {
            header.title = resultsTableController.sections[section].title
        }

        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let tableSection: GroupedTableSection
        if tableView == self.tableView {
            tableSection = sections[section]
        } else {
            tableSection = resultsTableController.sections[section]
        }

        return (tableSection.title != nil) ? 50.0 : 20.0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return sections.count
        } else {
            return resultsTableController.sections.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return sections[section].items.count
        } else {
            return resultsTableController.sections[section].items.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(ZERO_HEADER_HEIGHT)
    }

    // MARK: - HLCustomPointSelectionDelegate methods

    func didSelectCustomSearchLocationPoint(_ searchLocationPoint: HDKSearchLocationPoint) {
    }
}

extension ASTGroupedSearchVC: HLNearbyCitiesDetectionDelegate {

    func nearbyCitiesDetectionStarted(_ notification: Notification!) {
        tableView.reloadData()
    }

    func nearbyCitiesDetected(_ notification: Notification!) {
        resetTableContent()
        tableView.reloadData()
    }

    func nearbyCitiesDetectionCancelled(_ notification: Notification!) {
        reactToCityDetectionFailed()
    }

    func nearbyCitiesDetectionFailed(_ notification: Notification!) {
        reactToCityDetectionFailed()
    }

    func locationDetectionFailed(_ notification: Notification!) {
        reactToCityDetectionFailed()
    }

    func locationServicesAccessFailed(_ notification: Notification!) {
        reactToCityDetectionFailed()
    }

    func reactToCityDetectionFailed() {
        resetTableContent()
        tableView.reloadData()
    }

}
