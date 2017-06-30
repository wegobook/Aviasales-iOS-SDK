import UIKit

class TableController: NSObject, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    var sections = [TableSectionProtocol]() {
        didSet { reload() }
    }

    func reload() {
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection index: Int) -> Int {
        guard let section = section(for: index) else { return 0 }
        return section.numberOfRows()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection index: Int) -> String? {
        guard self.tableView(tableView, viewForHeaderInSection: index) == nil else { return nil }
        guard let section = section(for: index) as? TableSection else { return nil }
        return section.name
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        guard let section = section(for: index) else { return nil }
        return section.headerView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        guard let sections = section(for: index) else { return 0 }
        return sections.headerHeight()
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let item = item(for: indexPath) else { return false }
        return item.shouldHighlight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = item(for: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        item.selectionBlock?()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = item(for: indexPath) {
            return item.estimatedCellHeight
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = item(for: indexPath) else {
            assertionFailure("failed to get item for \(indexPath)")
            return UITableViewCell()
        }
        return item.cell(tableView: tableView, indexPath: indexPath)
    }

    // MARK: - Utility 

    func section(for index: Int) -> TableSectionProtocol? {
        guard sections.count > index else { return nil }
        return sections[index]
    }

    func item(for indexPath: IndexPath) -> TableItem? {
        guard let section = section(for: indexPath.section) as? TableSection else { return nil }
        guard section.items.count > indexPath.row else { return nil }
        return section.items[indexPath.row]
    }
}
