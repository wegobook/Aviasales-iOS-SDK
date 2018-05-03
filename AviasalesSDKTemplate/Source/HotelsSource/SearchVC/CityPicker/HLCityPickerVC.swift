import UIKit

@objc protocol HLCityPickerDelegate: class, NSObjectProtocol {
    func cityPicker(_ picker: HLCityPickerVC, didSelectCity: HDKCity)
    func cityPicker(_ picker: HLCityPickerVC, didSelectHotel: HDKHotel)
    func cityPicker(_ picker: HLCityPickerVC, didSelectAirport: HDKAirport)
    func cityPicker(_ picker: HLCityPickerVC, didSelectLocationPoint: HDKSearchLocationPoint)
}

@objcMembers
class HLCityPickerVC: ASTGroupedSearchVC {

    let minimalSearchStringLength = 2
    var cancelToken: CancelToken?
    var initialSearchText: String?
    weak var delegate: HLCityPickerDelegate?

    private var startSearchWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_SEARCH_FORM_CITY_TITLE")
        searchController.searchBar.placeholder = NSLS("HL_LOC_CITY_PLACEHOLDER_TEXT")
        searchController.searchBar.becomeFirstResponder()
        resultsTableController.tableView.hl_registerNib(withName: JRAirportPickerCellWithInfo.hl_reuseIdentifier())
        resetTableContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if initialSearchText != nil {
            searchController.searchBar.text = initialSearchText
            initialSearchText = nil
        }
    }

    override func resetTableContent() {
        super.resetTableContent()

        var points = [customLocationPointItem()]
        if HLSearchUserLocationPoint.forCurrentLocation() != nil {
            points.append(userLocationItem())
        } else {
            points.append(locationRequestItem())
        }
        sections.append(GroupedTableSection(title: nil, items: points))

        if let nearbyCities = HLNearbyCitiesDetector.shared().nearbyCities {
            sections.append(GroupedTableSection(title: NSLS("LOC_CITY_PICKER_HEADER_TITLE_NEARBY"), items: nearbyCities))
        }

        if let recentDestinations = HDKDefaultsSaver.getRecentSearchDestinations() {
            sections.append(GroupedTableSection(title: NSLS("LOC_SEARCH_HEADER_TITLE_RECENT"), items: recentDestinations as [AnyObject]))
        }
    }

    override func requestUserLocation() {
        registerForLocationManagerNotifications()
        super.requestUserLocation()
    }

    override func nearbyCitiesDetected(_ notification: Notification!) {
        userLocationSelected()
    }

    override func userLocationSelected() {
        if let locationPoint = HLSearchUserLocationPoint.forCurrentLocation() {
            delegate?.cityPicker(self, didSelectLocationPoint: locationPoint)
            goBack()
        }
    }

    func addLoadingItem() {
        resetTableContent()
        var resultSections: [GroupedTableSection] = []
        let errorItem = GroupedLoadingItem(title: NSLS("JR_AIRPORT_PICKER_SEARCHING_ON_SERVER_TEXT"))
        resultSections.append(GroupedTableSection(title: nil, items: [errorItem]))
        resultsTableController.sections = resultSections
        resultsTableController.tableView.reloadData()
    }

    // MARK: - IBActions methods

    func textFieldDidChange() {
        if let text = searchController.searchBar.text, text.count >= minimalSearchStringLength {
            startTimer()
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= minimalSearchStringLength {
            startTimer()
        } else {
            resultsTableController.sections = []
            resultsTableController.tableView.reloadData()
        }
    }

    // MARK: - Autocomplete completion methods

    func citiesAutocompletionLoaderDidLoadCities(_ cities: [HDKCity]?, hotels: [HDKHotel]?, airports: [HDKAirport]?) {

        var resultSections: [GroupedTableSection] = []
        if let cities = cities, cities.count > 0 {
            resultSections.append(GroupedTableSection(title: NSLS("LOC_CITY_PICKER_HEADER_TITLE_CITIES"), items: Array(cities.prefix(5))))
        }

        if let airports = airports, airports.count > 0 {
            resultSections.append(GroupedTableSection(title: NSLS("LOC_CITY_PICKER_HEADER_TITLE_AIRPORTS"), items: airports))
        }

        if let hotels = hotels, hotels.count > 0 {
            resultSections.append(GroupedTableSection(title: NSLS("LOC_CITY_PICKER_HEADER_TITLE_HOTELS"), items: hotels))
        }

        if hotels?.count == 0 && cities?.count == 0 && airports?.count == 0 {
            let errorItem = GroupedTableItem(title: NSLS("HL_LOC_NO_CITY_PICKER_RESULTS"))
            resultSections.append(GroupedTableSection(title: nil, items: [errorItem]))
        }
        resultsTableController.sections = resultSections
        resultsTableController.tableView.reloadData()
    }

    func citiesAutocompletionLoaderFailed(_ error: Error) {
        resetTableContent()
        var resultSections: [GroupedTableSection] = []
        let errorItem = GroupedTableItem(title: NSLS("HL_LOC_NO_CITY_PICKER_RESULTS"))
        resultSections.append(GroupedTableSection(title: nil, items: [errorItem]))
        resultsTableController.sections = resultSections
        resultsTableController.tableView.reloadData()
    }

    // MARK: - UITableViewDelegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Any
        if tableView === self.tableView {
            item = sections[indexPath.section].items[indexPath.row]
        } else {
            item = resultsTableController.sections[indexPath.section].items[indexPath.row]
        }

        if let groupedItem = item as? GroupedTableItem {
            groupedItem.action?()
            tableView.deselectRow(at: indexPath, animated: true)
            return
        } else if let city = item as? HDKCity {
            delegate?.cityPicker(self, didSelectCity:city)
            HDKDefaultsSaver.addRecentSearchDestination(item)
        } else if let hotel = item as? HDKHotel {
            delegate?.cityPicker(self, didSelectHotel:hotel)
            HDKDefaultsSaver.addRecentSearchDestination(item)
        } else if let airport = item as? HDKAirport {
            delegate?.cityPicker(self, didSelectAirport: airport)
            HDKDefaultsSaver.addRecentSearchDestination(airport)
        } else if let locationPoint = item as? HLSearchUserLocationPoint {
            delegate?.cityPicker(self, didSelectLocationPoint: locationPoint)
        }

        super.tableView(tableView, didSelectRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Any
        if tableView == self.tableView {
            item = sections[indexPath.section].items[indexPath.row]
        } else {
            item = resultsTableController.sections[indexPath.section].items[indexPath.row]
        }
        if let groupedItem = item as? GroupedTableItem {
            return groupedItem.createCell(tableView, indexPath: indexPath)
        } else {
            let cell: HLGroupedTableCell = tableView.dequeueReusableCell(withIdentifier: HLGroupedTableCell.hl_reuseIdentifier(), for: indexPath) as! HLGroupedTableCell
            if let city = item as? HDKCity {
                cell.title = StringUtils.cityName(withStateAndCountry: city)
                cell.showDetailsLabel = false
                cell.icon.image = nil
            } else if let hotel = item as? HDKHotel {
                cell.title = hotel.name
                cell.details = StringUtils.cityName(withStateAndCountry: hotel.city)
                cell.showDetailsLabel = true
                cell.icon.image = nil
            } else if let aiport = item as? HDKAirport {
                cell.title = aiport.name
                cell.showDetailsLabel = false
                cell.icon.image = nil
            }
            return cell
        }
    }

    // MARK: - HLCustomPointSelectionDelegate methods

    override func didSelectCustomSearchLocationPoint(_ searchLocationPoint: HDKSearchLocationPoint) {        delegate?.cityPicker(self, didSelectLocationPoint: searchLocationPoint)
        goBack()
    }

    // MARK: - Private methods

    private func startTimer() {
        startSearchWorkItem?.cancel()
        startSearchWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            guard let searchText = self.searchController.searchBar.text, searchText.count >= self.minimalSearchStringLength else { return }

            self.cancelToken?.cancel()
            self.cancelToken = CancelToken()
            ServiceLocator.shared.api.autocomplete(text: searchText, limit: 10).promise(cancelToken: self.cancelToken).then { autocompleteResp in
                self.citiesAutocompletionLoaderDidLoadCities(autocompleteResp.cities, hotels: autocompleteResp.hotels, airports: autocompleteResp.airports)
            }.catch { error in
                self.citiesAutocompletionLoaderFailed(error)
            }
            self.addLoadingItem()
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7, execute: startSearchWorkItem!)
    }
}

extension HLCityPickerVC: HLLocationManagerDelegate {

    func locationUpdatedNotification(_ notification: Notification!) {
        if let locationPoint = HLSearchUserLocationPoint.forCurrentLocation() {
            delegate?.cityPicker(self, didSelectLocationPoint: locationPoint)
            unregisterNotificationResponse()
            goBack()
        }
    }
}
