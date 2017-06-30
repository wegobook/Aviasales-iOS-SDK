class ErrorItem: TableItem {

    var buttonHandler: (() -> Void)!

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        return 90.0
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let errorCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsErrorTableCell.hl_reuseIdentifier()) as! HLHotelDetailsErrorTableCell
        errorCell.titleText = NSLS("HL_HOTEL_DETAIL_INFORMATION_LOADING_ERROR_TITLE")
        errorCell.buttonText = NSLS("HL_HOTEL_DETAIL_TRY_AGAIN_BUTTON_TITLE")
        errorCell.buttonHandler = buttonHandler

        return errorCell
    }
}
