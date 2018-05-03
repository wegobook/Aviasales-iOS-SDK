import Foundation

class HotelDetailsNavBarView: UIView {

    let nameLabel = UILabel()
    let starsView = UIView()
    var variant: HLResultVariant

    init(variant: HLResultVariant) {
        self.variant = variant
        super.init(frame: CGRect.zero)
        createSubviews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nameLabel.text = variant.hotel.name

        addSubview(starsView)
        starsView.drawWhiteStars(variant.hotel.stars, fromPoint: CGPoint(), offset: 2)

    }

    func setupConstraints() {
        nameLabel.autoPinEdge(toSuperviewEdge: .left)
        nameLabel.autoPinEdge(toSuperviewEdge: .top)
        nameLabel.autoPinEdge(toSuperviewEdge: .right)

        starsView.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 2)
        starsView.autoSetDimension(.height, toSize: 12)
        starsView.autoPinEdge(toSuperviewEdge: .bottom)
        starsView.autoAlignAxis(toSuperviewAxis: .vertical)
    }
}
