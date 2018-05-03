import HotellookSDK

class PointSelectionVC: ASTGroupedSearchVC {

    weak var selectionDelegate: PointSelectionDelegate?
    var points: [HDKLocationPoint]?

    override var searchInfo: HLSearchInfo? {
        didSet {
            if let city = searchInfo?.city {
                points = city.points
            } else {
                points = HLPoiManager.allUniquePoints(forCities: searchInfo?.locationPoint?.nearbyCities)
            }
            resetTableContent()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLS("HL_LOC_FILTER_DISTANCE_CRITERIA")
        searchController.searchBar.placeholder = NSLS("HL_LOC_FILTERS_POINT_PLACEHOLDER_TEXT")
    }

    override func resetTableContent() {
        super.resetTableContent()

        if let city = searchInfo?.city {
            if let points = HDKDefaultsSaver.getRecentFilterPoints(for: city) as? [HDKLocationPoint] {
                let items = convertLocationPointsToGroupedItems(points)
                sections.append(GroupedTableSection(title: NSLS("LOC_SEARCH_HEADER_TITLE_RECENT"), items: items))
            }
        }
        sections.append(GroupedTableSection(title: nil, items: coordinateItems()))

        if let points = points, points.count > 0 {
            if let airportSection = section(points, category: HDKLocationPointCategory.kAirport, title: NSLS("HL_LOC_FILTERS_POINT_AIRPORTS_TEXT")) {
                sections.append(airportSection)
            }
            if let stationSection = section(points, category: HDKLocationPointCategory.kTrainStation, title: NSLS("HL_LOC_FILTERS_POINT_TRAIN_STATIONS_TEXT")) {
                sections.append(stationSection)
            }
            addSeasonItems(points, seasonCategory: HDKSeason.kBeachSeasonCategory, pointsCategory: HDKLocationPointCategory.kBeach, title: NSLS("HL_LOC_FILTERS_POINT_BEACHES_TEXT"))
            if let sightSection = section(points, category: HDKLocationPointCategory.kSight, title: NSLS("HL_LOC_FILTERS_POINT_POI_TEXT")) {
                sections.append(sightSection)
            }
        }
    }

    private func coordinateItems() -> [GroupedTableItem] {

        var result: [GroupedTableItem] = []

        result = addCurrentLocationItem(searchInfo!, points: result)

        if searchInfo?.searchInfoType != .customLocation {
            result.append(customLocationPointItem())
        }

        if let city = searchInfo?.city ?? searchInfo?.locationPoint?.city {
            let point = HLCityLocationPoint(city:city)
            result.append(convertPointToItem(point))
        } else if let cities = searchInfo?.locationPoint?.nearbyCities {
            for city in cities {
                let cityCenterPoint = HLCityLocationPoint(city:city)
                result.append(convertPointToItem(cityCenterPoint))
            }
        }

        if let seasons = self.searchInfo?.city?.seasons {
            if HLPoiManager.seasons(seasons, haveCategory: HDKSeason.kBeachSeasonCategory) && HLPoiManager.filterPoints(points, byCategories: [HDKLocationPointCategory.kBeach]).count > 0 {
                let genericPoint = HLGenericCategoryLocationPoint(category: HDKLocationPointCategory.kBeach)
                result.append(convertPointToItem(genericPoint))
            }

            if HLPoiManager.seasons(seasons, haveCategory: HDKSeason.kSkiSeasonCategory) && HLPoiManager.filterPoints(points, byCategories: [HDKLocationPointCategory.kSkilift]).count > 0 {
                let genericPoint = HLGenericCategoryLocationPoint(category: HDKLocationPointCategory.kSkilift)
                result.append(convertPointToItem(genericPoint))
            }
        }

        if HLPoiManager.filterPoints(points, byCategories: [HDKLocationPointCategory.kMetroStation]).count > 0 {
            let genericMetroPoint = HLGenericCategoryLocationPoint(category: HDKLocationPointCategory.kMetroStation)
            result.append(convertPointToItem(genericMetroPoint))
        }

        return result
    }

    private func addCurrentLocationItem(_ searchInfo: HLSearchInfo, points: [GroupedTableItem]) -> [GroupedTableItem] {
        var result: [GroupedTableItem] = points
        if let locationPoint = searchInfo.locationPoint {
            let point = HDKLocationPoint(name: NSLS("HL_LOC_SEARCH_POINT_TEXT"), location:locationPoint.location)
            result.append(convertPointToItem(point))
        } else {
            if HLLocationManager.shared().location() != nil {
                if let currentCity = HLNearbyCitiesDetector.shared().nearbyCities?.first {
                    if currentCity.isEqual(self.searchInfo?.city) {
                        result.append(userLocationItem())
                    }
                }
            } else {
                result.append(locationRequestItem())
            }
        }

        return result
    }

    private func addSeasonItems(_ points: [HDKLocationPoint], seasonCategory: String, pointsCategory: String, title: String) {
        let seasonPoints = HLPoiManager.points(from: points, pointsCategory:pointsCategory, seasonCategory: seasonCategory, seasons: searchInfo?.city?.seasons)
        if seasonPoints.count > 0 {
            let items = convertLocationPointsToGroupedItems(seasonPoints)
            sections.append(GroupedTableSection(title: title, items: items))
        }
    }

    private func section(_ points: [HDKLocationPoint], category: String, title: String) -> GroupedTableSection? {
        var filteredPoints = HLPoiManager.filterPoints(points, byCategories: [category])
        if filteredPoints.count > 0 {
            filteredPoints = sortPoisAlphabetical(filteredPoints)
            let items = convertLocationPointsToGroupedItems(filteredPoints)

            return GroupedTableSection(title: title, items: items)
        }

        return nil
    }

    private func convertLocationPointsToGroupedItems(_ points: [HDKLocationPoint]) -> [GroupedTableItem] {
        var items: [GroupedTableItem] = []
        for point in points {
            items.append(convertPointToItem(point))
        }
        return items
    }

    private func convertPointToItem(_ point: HDKLocationPoint) -> GroupedTableItem {
        return GroupedTableItem(title: StringUtils.locationPointName(point),
                                action: { [weak self] in
                                    self?.selectionDelegate?.locationPointSelected?(point)
                                    self?.goBack()
            }, icon: nil)
    }

    private func sortPoisAlphabetical(_ poi: [HDKLocationPoint]) -> [HDKLocationPoint] {
        return poi.sorted(by: { (poi1: HDKLocationPoint, poi2: HDKLocationPoint) -> Bool in
            return poi1.name < poi2.name
        })
    }

    private func searchPois(_ poi: [HDKLocationPoint], searchString: String) -> [HDKLocationPoint] {
        return poi.filter { $0.name.range(of: searchString, options: .caseInsensitive, range: nil, locale: nil) != nil }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            if let points = points {
                sections = []
                let filteredPois = searchPois(points, searchString: searchText)
                if filteredPois.count > 0 {
                    let items = convertLocationPointsToGroupedItems(filteredPois)
                    sections.append(GroupedTableSection(title: NSLS("HL_FILTERS_NAME_SEARCH_RESULTS"), items: items))
                }
                resultsTableController.sections = sections
                resultsTableController.tableView.reloadData()
            }
        }
    }

    override func userLocationSelected() {
        guard let location = HLLocationManager.shared().location() else { return }
        let point = HLUserLocationPoint(location: location)
        selectionDelegate?.locationPointSelected?(point)
        goBack()
    }

    // MARK: - UITableViewDataSource methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let item = sections[indexPath.section].items[indexPath.row]

        if let groupedItem = item as? GroupedTableItem {
            cell = groupedItem.createCell(tableView, indexPath: indexPath)
        } else {
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        if let groupedCell = cell as? HLGroupedTableCell {
            groupedCell.showDetailsLabel = false
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        if let groupedItem = item as? GroupedTableItem {
            groupedItem.action?()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - HLCustomPointSelectionDelegate methods

    override func didSelectCustomSearchLocationPoint(_ searchLocationPoint: HDKSearchLocationPoint) {
        let locationPoint = HDKLocationPoint(name: NSLS("HL_LOC_POINT_ON_MAP_TEXT"), location:searchLocationPoint.location)
        selectionDelegate?.locationPointSelected?(locationPoint)
        goBack()
    }
}
