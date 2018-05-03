import UIKit

class HLNameFilterVC: ASTGroupedSearchVC, HLFilterDelegate {

    var filter: Filter! {
        didSet {
            self.privateFilter = self.filter.copy() as! Filter
            self.privateFilter.delegate = self
            self.privateFilter.searchResult = self.filter.searchResult
        }
    }

    var privateFilter: Filter!

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLS("HL_LOC_FILTER_HOTEL_NAME_SECTION")
        searchController.searchBar.placeholder = NSLS("HL_FILTERS_NAME_TEXTFIELD_PLACEHOLDER")
        searchController.searchBar.returnKeyType = .done
    }

    override func viewWillAppear(_ animated: Bool) {
        if let recentFilters = HDKDefaultsSaver.getRecentSelectedNameFilter(), recentFilters.count > 0 {
            sections.append(GroupedTableSection(title: NSLS("LOC_SEARCH_HEADER_TITLE_RECENT"), items: recentFilters as [AnyObject]))
        }
        searchController.searchBar.text = privateFilter.keyString

        super.viewWillAppear(animated)
    }

    override func goBack() {
        if let string = privateFilter.keyString {
            if string.count > 0 {
                HDKDefaultsSaver.addRecentSelectedNameFilter(self.privateFilter.keyString)
            }
        }

        privateFilter.delegate = nil
        filter.keyString = privateFilter.keyString
        filter.filter()

        super.goBack()
    }

    override func resetTableContent() {
        super.resetTableContent()

        if let items = HDKDefaultsSaver.getRecentSelectedNameFilter() {
            sections.append(GroupedTableSection(title: NSLS("LOC_SEARCH_HEADER_TITLE_RECENT"), items: items))
        }
    }

    // MARK: - UITableViewDataSource methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLGroupedTableCell.hl_reuseIdentifier()) as! HLGroupedTableCell
        let item = sections[indexPath.section].items[indexPath.row]
        if let string = item as? NSString {
            cell.title = string as String
        } else if let variant = item as? HLResultVariant {
            cell.title = variant.hotel.name
        }
        cell.showDetailsLabel = false
        cell.icon.image = nil

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: HLGroupedTableCell = tableView.cellForRow(at: indexPath) as! HLGroupedTableCell
        privateFilter.keyString = cell.title

        super.tableView(tableView, didSelectRowAt: indexPath)
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count > 0 {
            privateFilter.keyString = searchText
            privateFilter.filter()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        privateFilter.keyString = textField.text
        privateFilter.filter()
        goBack()

        return true
    }

    // MARK: - HLFilterDelegate methods

    func didFilterVariants() {
        DispatchQueue.global().async {
            var filtered: [HLResultVariant] = self.privateFilter.filteredVariants ?? []
            let key = self.privateFilter.keyString.lowercased()
            filtered.sort { variant1, variant2 -> Bool in
                if let range1: Range = variant1.hotel.name?.lowercased().range(of: key) ?? variant1.hotel.latinName?.lowercased().range(of: key),
                    let range2: Range = variant2.hotel.name?.lowercased().range(of: key) ?? variant2.hotel.latinName?.lowercased().range(of: key) {
                    return range1.lowerBound < range2.lowerBound
                }

                return false
            }

            let maxLength = min(filtered.count, 15)
            filtered = Array(filtered[0 ..< maxLength]).sorted(by: {$0.hotel.name ?? "" < $1.hotel.name ?? ""})

            DispatchQueue.main.async {
                self.resetTableContent()
                if filtered.count > 0 {
                    self.sections.append(GroupedTableSection(title: NSLS("HL_FILTERS_NAME_SEARCH_RESULTS"), items: filtered))
                }
                self.resultsTableController.sections = self.sections
                self.resultsTableController.tableView.reloadData()
            }
        }
    }
}
