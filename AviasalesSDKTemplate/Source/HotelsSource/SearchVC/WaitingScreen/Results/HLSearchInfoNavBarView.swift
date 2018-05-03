import Foundation

@objcMembers
@IBDesignable class HLSearchInfoNavBarView: HLAutolayoutView {

    var cityLabel: UILabel!
    var guestsLabel: UILabel!

    override func initialize() {
        createSubviews()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        cityLabel.text = "Кастрокаро-Терме-е-Терра-Соль-Фасоль-Терра-Инкогнито"
        guestsLabel.text = "8 авг - 12 авг; 2 взрослых, 3 ребенка"
    }

    private func createSubviews() {
        cityLabel = UILabel()
        cityLabel.textAlignment = .center
        cityLabel.textColor = .white
        cityLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        addSubview(cityLabel)

        guestsLabel = UILabel()
        guestsLabel.textAlignment = .center
        guestsLabel.textColor = .white
        guestsLabel.font = UIFont.systemFont(ofSize: 12.0)
        addSubview(guestsLabel)
    }

    override func setupConstraints() {
        cityLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        guestsLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
        guestsLabel.autoPinEdge(.top, to: .bottom, of: cityLabel, withOffset: 1)
    }

    func configureForSearchInfo(_ searchInfo: HLSearchInfo?, title: String?) {
        guestsLabel.text = StringUtils.searchInfoString(by: searchInfo)
        cityLabel.text = title
    }

    func configureForSearchInfo(_ searchInfo: HLSearchInfo) {
        let cityName = StringUtils.searchDestinationDescriptionString(by: searchInfo)
        configureForSearchInfo(searchInfo, title: cityName)
    }

}
