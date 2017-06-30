class GateLogoView: HLAutolayoutView {

    let nameLabel = UILabel()
    let iconImageView = UIImageView()

    override func initialize() {
        backgroundColor = UIColor.clear
        setupSubviews()
    }

    private func setupSubviews() {
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        nameLabel.textColor = JRColorScheme.darkTextColor()
        nameLabel.alpha = 1.0
        addSubview(nameLabel)

        iconImageView.alpha = 0.0
        addSubview(iconImageView)
    }

    override func setupConstraints() {
        iconImageView.autoPinEdgesToSuperviewEdges()
        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: iconImageView)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing)
    }

    func configure(forGate gate: HDKGate, maxImageSize: CGSize, alignment: HLUrlUtilsImageAlignment = .left) {
        layoutIfNeeded()

        nameLabel.textAlignment = imageAlignmentToTextAlignment(alignment)
        nameLabel.text = gate.name

        guard let intGateId = Int(gate.gateId) else { return }
        let url = HLUrlUtils.gateIconURL(intGateId, size: maxImageSize, alignment: alignment)
        iconImageView.hl_setImageAndHideLabelWithFadeForUrl(url, label: nameLabel)
    }

    private func imageAlignmentToTextAlignment(_ imageAlignment: HLUrlUtilsImageAlignment) -> NSTextAlignment {
        switch imageAlignment {
        case .center: return .center
        case .left: return .left
        case .right: return .right
        }
    }
}
