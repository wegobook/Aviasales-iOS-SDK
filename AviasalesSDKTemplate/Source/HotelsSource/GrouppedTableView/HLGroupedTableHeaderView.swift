class HLGroupedTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = title
        titleLabel.textColor = JRColorScheme.darkTextColor()
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightBold)
    }

    class func preferredHeight(_ hasTitle: Bool) -> CGFloat {
        return hasTitle ? 51.0 : 15.0
    }

}
