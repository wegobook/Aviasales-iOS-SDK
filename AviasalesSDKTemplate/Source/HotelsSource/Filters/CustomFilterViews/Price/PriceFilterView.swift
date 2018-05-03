import UIKit

@objc protocol PriceFilterViewDelegate: NSObjectProtocol {
    func filterApplied()
}

@objcMembers
@IBDesignable class PriceFilterView: UIView, HLRangeSliderDelegate {

    @IBOutlet weak var slider: HLRangeSlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    weak var delegate: PriceFilterViewDelegate?

    private var sliderCalculator: HLPriceSliderCalculator?
    var filter: Filter?
    let appearanceDuration: TimeInterval = 0.5

    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    func configure(withFilter filter: Filter) {
        self.filter = filter

        updateRangeValueLabel(filter)

        sliderCalculator = filter.priceSliderCalculator

        guard sliderCalculator != nil else { return }

        slider.lowerValue = filter.graphSliderMinValue
        slider.upperValue = filter.graphSliderMaxValue
        updateRangeValueLabel(filter)
    }

    // MARK: - Private

    private func initialize() {
        let view = loadViewFromNib("PriceFilterView", self)!
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()

        slider.trackBackgroundImage = JRColorScheme.sliderMinImage()
        slider.trackImage = JRColorScheme.sliderMaxImage()
        slider.lowerHandleImageNormal = UIImage(named: "JRSliderImg")
        slider.upperHandleImageNormal = UIImage(named: "JRSliderImg")

        slider.addTarget(self, action: #selector(sliderEditingDidEnd), for: .editingDidEnd)
        slider.delegate = self

        titleLabel.text = NSLS("HL_LOC_FILTER_PRICE_CRITERIA")
    }

    func sliderValueChanged() {
        filter?.graphSliderMinValue = slider.lowerValue
        filter?.graphSliderMaxValue = slider.upperValue
        updateRangeValueLabel(filter!)
    }

    @objc func sliderEditingDidEnd() {
        delegate?.filterApplied()
    }

    fileprivate func updateRangeValueLabel(_ filter: Filter) {
        valueLabel.attributedText = StringUtils.attributedRangeValueText(currency: filter.searchInfo.currency, minValue:Float(filter.currentMinPrice), maxValue: Float(filter.currentMaxPrice))

        let sliderWidth = slider.bounds.width == 0 ? 1.0 : slider.bounds.width - slider.rangeSliderHorizontalOffset * 2

        layoutIfNeeded()

        let linearSpace = slider.lowerHandle.bounds.width

        var lowerGraphValue = slider.lowerCenter.x - slider.rangeSliderHorizontalOffset
        if lowerGraphValue < linearSpace {
            lowerGraphValue += (lowerGraphValue - linearSpace) / 2
        }

        var upperGraphValue = slider.upperCenter.x - slider.rangeSliderHorizontalOffset
        if upperGraphValue > sliderWidth - linearSpace {
            upperGraphValue += (linearSpace - sliderWidth + upperGraphValue) / 2
        }
    }

    func minValueChanged() {
        sliderValueChanged()
    }

    func maxValueChanged() {
        sliderValueChanged()
    }
}
