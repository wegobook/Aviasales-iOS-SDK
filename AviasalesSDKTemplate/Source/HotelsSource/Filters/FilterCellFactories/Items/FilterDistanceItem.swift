class FilterDistanceItem: FilterSliderItem {

    weak var pointSelectionDelegate: PointSelectionDelegate?

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HLDistanceFilterCell.hl_reuseIdentifier(), for: indexPath) as! HLDistanceFilterCell
        cell.filterControlDelegate = controlDelegate
        cell.minValue = filter.minDistance
        cell.maxValue = filter.maxDistance
        cell.currentValue = filter.currentMaxDistance
        cell.selectionStyle = .none

        cell.pointSelectionDelegate = pointSelectionDelegate
        cell.pointButton.setTitle(filter.distanceLocationPoint?.name ?? "", for: UIControlState())

        return cell
    }
}
