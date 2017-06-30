import Foundation

struct PopoverItem {
    let title: String
    let selected: Bool
    let action: (() -> Void)?
}

class PopoverItemPickerVC: HLCommonVC, UITableViewDataSource, UITableViewDelegate {

    private var items: [PopoverItem]
    private var tableView: UITableView!

    override func loadView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        setupTableView()
        view = tableView
    }

    public init(items: [PopoverItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func prefferedSizeForPopoverPresentation(itemsCount: Int) -> CGSize {

        let maxItemsOnScreen = 5.5
        let rowHeight: CGFloat = 44.0

        let dItemsCount = Double(itemsCount)
        let itemsOnScreen = dItemsCount > maxItemsOnScreen ? maxItemsOnScreen : dItemsCount
        let popoverHeight: CGFloat = CGFloat(itemsOnScreen) * rowHeight

        return CGSize(width: 250.0, height: popoverHeight)
    }

    private func setupTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.register(PopoverItemPickerCell.self, forCellReuseIdentifier: PopoverItemPickerCell.hl_reuseIdentifier())
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopoverItemPickerCell.hl_reuseIdentifier(), for: indexPath) as! PopoverItemPickerCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
        let item = items[indexPath.row]
        item.action?()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(0.0001)
    }
}
