class FilterStarItem: CustomFilterViewTableItem {

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 106
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StarFilterCell.hl_reuseIdentifier(), for: indexPath) as! StarFilterCell
        cell.configure(with: filter)
        cell.selectionStyle = .none

        return cell
    }

}
