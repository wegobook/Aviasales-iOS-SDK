import UIKit

class FilterSelectionSection: BaseSection {

    override func headerView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear

        return headerView
    }

    override func heightForCell(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionFilterCell.hl_reuseIdentifier(), for: indexPath) as! SelectionFilterCell
        if let item = items[indexPath.row] as? FilterSelectionItem {
            cell.setup(item)
        }

        return cell
    }
}

class FilterSelectionVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate {
    private var sections: [FilterSelectionSection]!
    private var filter: Filter!
    private let defaultHeaderHeight: CGFloat = 15
    private let defaultFooterHeight: CGFloat = 20

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.hl_registerNib(withName: SelectionFilterCell.hl_reuseIdentifier())
        tableView.reloadData()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLS("HL_LOC_FILTER_DROP_BUTTON"), style: .done, target: self, action: #selector(FilterSelectionVC.reset))
    }

    func configure(with items: [[FilterSelectionItem]], title: String, and filter: Filter) {
        self.title = title
        self.sections = items.map({ FilterSelectionSection(name: nil, items: $0)})
        self.filter = filter
    }

    func contentHeight() -> CGFloat {
        var contentHeight: CGFloat = 44.0
        for section in sections {
            contentHeight += defaultHeaderHeight
            for _ in section.items {
                contentHeight += 44
            }
        }
        contentHeight += defaultFooterHeight

        return contentHeight
    }

    @objc func reset() {
        self.iterateFilterItems { item in
            deactivateItem(item: item)
            return false
        }

        filter.filter()
        self.tableView.reloadData()
    }

    private func deactivateItem(item: FilterSelectionItem) {
        if item.active {
            item.changeValue(for: filter)
            item.active = item.isActive(for: filter)
            item.cell?.active = item.active
        }
    }

    private func close() {
        if iPhone() {
            self.goBack()
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    private func hasActiveItems() -> Bool {
        var hasActiveItems = false
        iterateFilterItems(block: { item in
            hasActiveItems = item.active
            return hasActiveItems
        })

        return hasActiveItems
    }

    private func iterateFilterItems( block: (FilterSelectionItem) -> Bool ) {
        for section in sections {
            for item in section.items {
                if let item = item as? FilterSelectionItem {
                    let stop = block(item)
                    if stop {
                        return
                    }
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cell(tableView, indexPath: indexPath)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sections.count - 1 ? defaultFooterHeight : CGFloat(0.0001)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].heightForCell(tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.selectionBlock?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
