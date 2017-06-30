class ExpandItem: TableItem {

    var title: String?
    var height: CGFloat = 50.0
    var shouldShowArrow = false

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return height
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpandCell.hl_reuseIdentifier(), for: indexPath) as! ExpandCell
        cell.selectionBlock = selectionBlock
        cell.title = title
        cell.last = last

        if shouldShowArrow {
            cell.showArrow()
        } else {
            cell.hideArrow()
        }

        return cell
    }
}
