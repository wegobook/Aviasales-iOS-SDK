import Foundation

class FiltersNavBarView: HLAutolayoutView {

    var titleLabel = UILabel()
    var hotelsLeftLabel = UILabel()

    override func initialize() {
        createSubviews()
        titleLabel.text = NSLS("HL_FILTER_BUTTON_TITLE_LABEL")
    }

    private func createSubviews() {
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)

        hotelsLeftLabel.textAlignment = .center
        addSubview(hotelsLeftLabel)
        hotelsLeftLabel.textColor = .white
        hotelsLeftLabel.font = UIFont.systemFont(ofSize: 12.0)
    }

    override func setupConstraints() {
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
        hotelsLeftLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
        hotelsLeftLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 0)
    }

    func hotelsLeft(_ filtered: Int, outOf total: Int) {
        hotelsLeftLabel.text = StringUtils.filteredHotelsDescription(withFiltered: filtered, total: total)
    }

}
