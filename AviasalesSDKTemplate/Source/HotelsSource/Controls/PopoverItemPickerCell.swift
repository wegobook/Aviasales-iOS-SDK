import Foundation

class PopoverItemPickerCell: UITableViewCell {
    let activeImageView = UIImageView()
    let nameLabel = UILabel()

    var nameToActiveImageConstraint: NSLayoutConstraint?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear

        createSubviews()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        nameLabel.font = UIFont.systemFont(ofSize: 15.0)
        contentView.addSubview(nameLabel)

        activeImageView.image = UIImage(named: "sortActiveIcon")
        contentView.addSubview(activeImageView)
    }

    private func createConstraints() {
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        nameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15, relation: .greaterThanOrEqual)
        nameToActiveImageConstraint = nameLabel.autoPinEdge(.trailing, to: .leading, of: activeImageView, withOffset: 10)

        activeImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        activeImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        activeImageView.autoSetDimensions(to: CGSize(width: 20, height: 20))
    }

    func configure(item: PopoverItem) {
        nameLabel.text = item.title
        active = item.selected
    }

    var active: Bool = false {
        didSet {
            nameLabel.textColor = active ? JRColorScheme.actionColor() : JRColorScheme.darkTextColor()
            activeImageView.isHidden = !active
            nameToActiveImageConstraint?.isActive = active
        }
    }
}
