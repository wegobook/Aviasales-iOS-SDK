import UIKit

class HotelDetailsMoreTableVC: HotelDetailsMoreVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var contentTable: UITableView!

    var sections: [TableSection] = []
    private let sectionFooterNib = UINib(nibName: "HLGroupedTableHeaderView", bundle: nil)

    override init(variant: HLResultVariant, nibName: String = "HotelDetailsMoreTableVC") {
        super.init(variant: variant, nibName: nibName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentTable.backgroundColor = JRColorScheme.mainBackgroundColor()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]

        return section.cell(tableView, indexPath: indexPath)
    }

    // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.selectionBlock?()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]

        return section.heightForCell(tableView, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sections.count - 1 {
            return iPad() ? 15 : 20
        } else {
            return CGFloat(ZERO_HEADER_HEIGHT)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let views = self.sectionFooterNib.instantiate(withOwner: nil, options: nil).compactMap { $0 as? UIView }
        let footer = views.first
        if let groupedHeader = footer as? HLGroupedTableHeaderView {
            groupedHeader.title = ""
        }

        return footer
    }
}
