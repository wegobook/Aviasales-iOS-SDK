import UIKit

class HLDistanceFilterCell: HLSliderFilterCell {

    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet weak var pointButton: UIButton!

    weak var pointSelectionDelegate: PointSelectionDelegate?

    @IBOutlet var sliderToLabelConstraint: NSLayoutConstraint!
    @IBOutlet var labelToSuperviewTrailingConstraint: NSLayoutConstraint!
    var sliderToSuperviewTrailingConstraint: NSLayoutConstraint?

    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 1.0 {
        didSet {
            updateValueLabel(currentValue)
            if minValue != maxValue {
                let value = HLSliderCalculator.calculateSliderLogValue(withValue: Double(currentValue), minValue: Double(minValue), maxValue: Double(maxValue))
                slider.value = Float(value)
            }
        }
    }

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = NSLS("HL_LOC_FILTER_DISTANCE_CRITERIA")
        slider.addTarget(self, action: #selector(HLDistanceFilterCell.sliderValueChanged), for: .valueChanged)
        updateValueLabel(1.0)

        pointButton.setTitle(NSLS("HL_LOC_FILTER_DISTANCE_CRITERIA_CENTER"), for: .normal)

        let activeImage = UIImage(named: "sliderActiveImage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        let inactiveImage = UIImage(named: "sliderInactiveImage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))

        slider.setThumbImage(UIImage(named: "JRSliderImg"), for: .normal)
        slider.setMinimumTrackImage(activeImage, for: .normal)
        slider.setMaximumTrackImage(inactiveImage, for: .normal)

        slider.setMinimumTrackImage(JRColorScheme.sliderMaxImage(), for: .normal)
        slider.setMaximumTrackImage(JRColorScheme.sliderMinImage(), for: .normal)

        pointButton.setTitleColor(JRColorScheme.actionColor(), for: .normal)
        pointButton.tintColor = JRColorScheme.actionColor()
    }

    override func updateConstraints() {
        if sliderToSuperviewTrailingConstraint == nil {
            var sliderToSuperviewTrailingConstraintConstant = labelToSuperviewTrailingConstraint.constant + sliderToLabelConstraint.constant
            sliderToSuperviewTrailingConstraintConstant += StringUtils.attributedDistanceString(1000000).hl_width(withHeight: CGFloat.greatestFiniteMagnitude)
            sliderToSuperviewTrailingConstraint = slider.autoPinEdge(toSuperviewEdge: .trailing, withInset: sliderToSuperviewTrailingConstraintConstant)
        }

        super.updateConstraints()
    }

    @objc override func sliderValueChanged(_ sender: AnyObject, event: UIEvent) {
        let value = sliderExpValue(slider.value)
        updateValueLabel(value)

        super.sliderValueChanged(sender, event: event)
    }

    override func notifyDelegate() {
        let value = sliderExpValue(slider.value)
        filterControlDelegate?.didChangeMaximumDistance?(value)

        super.notifyDelegate()
    }

    // MARK: - Internal methods

    func hideSlider() {
        slider.isHidden = true
        valueLabel.text =  "—"
    }

    func showSlider() {
        slider.isHidden = false
    }

    func sliderExpValue(_ value: Float) -> CGFloat {
        let value = CGFloat(slider.value)
        let result = HLSliderCalculator.calculateExpValue(withSliderValue: Double(value), minValue: Double(minValue), maxValue: Double(maxValue))
        return CGFloat(result)
    }

    // MARK: - Private methods

    fileprivate func updateValueLabel(_ value: CGFloat) {
        let text: NSAttributedString = StringUtils.attributedDistanceString(value)
        valueLabel.attributedText = text
    }

    // MARK: - IBAction methods

    @IBAction private func openPointSelectionScreen() {
        pointSelectionDelegate?.openPointSelectionScreen()
    }
}
