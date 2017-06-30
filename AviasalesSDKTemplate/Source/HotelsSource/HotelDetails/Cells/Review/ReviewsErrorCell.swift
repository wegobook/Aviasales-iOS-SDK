import Foundation

class ReviewsErrorCell: UITableViewCell {
    let label = UILabel()
    let button = UIButton(type: UIButtonType.system)

    var buttonHandler: (() -> Void)?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
//        label.font = UIFont.appRegularFont(withSize: 14)
//        label.textColor = ColorScheme.current.appGrayColor
        label.text = NSLS("HL_HOTEL_DETAIL_REVIEWS_ERROR")
        contentView.addSubview(label)

        button.setTitle(NSLS("HL_HOTEL_DETAIL_TRY_AGAIN_BUTTON_TITLE"), for: .normal)
//        button.setTitleColor(ColorScheme.current.appGreenColor, for: .normal)
//        button.titleLabel?.font = UIFont.appMediumFont(withSize: 14)
        button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
        contentView.addSubview(button)
    }

    private func setupConstraints() {
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15), excludingEdge: .bottom)
        button.autoPinEdge(.leading, to: .leading, of: label)
        button.autoPinEdge(.top, to: .bottom, of: label, withOffset: 1)
        button.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15, relation: .greaterThanOrEqual)
        button.autoSetDimension(.height, toSize: 44)
        button.autoPinEdge(toSuperviewEdge: .bottom, withInset: 1)
    }

    @objc private func onButtonClicked() {
        buttonHandler?()
    }
}
