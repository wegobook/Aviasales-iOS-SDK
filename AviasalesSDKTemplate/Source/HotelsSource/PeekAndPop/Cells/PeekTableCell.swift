class PeekTableCell: UITableViewCell {

    var item: PeekItem?

    func configure(_ item: PeekItem) {
        self.item = item
        layoutIfNeeded()
    }
}
