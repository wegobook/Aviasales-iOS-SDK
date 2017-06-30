class MultipleLinesFeatureItem: FeatureItem {

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return MultipleLinesFeatureCell.preferredHeight(text: name, width: tableWidth, isFirst: first, isLast: last)
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: MultipleLinesFeatureCell.hl_reuseIdentifier(), for: indexPath) as! MultipleLinesFeatureCell
        c.configure(text: name, icon: image)
        c.isFirst = first
        c.isLast = last

        return c
    }
}
