import UIKit

class HLRatingFilterCell: HLSliderFilterCell {

    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!

    var currentRating: Int = 0 {
        didSet {
            slider.value = Float(currentRating) / 100.0
            updateValueLabel(currentRating)
        }
    }

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()

        slider.setThumbImage(UIImage(named: "JRSliderImg"), for: .normal)
        slider.setMaximumTrackImage(JRColorScheme.sliderMaxImage(), for: .normal)
        slider.setMinimumTrackImage(JRColorScheme.sliderMinImage(), for: .normal)

        slider.addTarget(self, action: #selector(HLRatingFilterCell.sliderValueChanged), for: .valueChanged)
        updateValueLabel(0)

        titleLabel.text = NSLS("HL_LOC_FILTER_RATING_CRITERIA")
    }
    
    @objc override func sliderValueChanged(_ sender: AnyObject, event: UIEvent) {
        let value = ratingForSliderValue(slider.value)
        updateValueLabel(value)
        
        super.sliderValueChanged(sender, event: event)
    }

    override func notifyDelegate() {
        let value = ratingForSliderValue(slider.value)
        filterControlDelegate?.didChangeMinimalRating?(value)

        super.notifyDelegate()
    }

    // MARK: - Internal methods

    func hideSlider() {
        slider.isHidden = true
        valueLabel.text = "—"
    }

    // MARK: - Private methods

    private func ratingForSliderValue(_ value: Float) -> Int {
        return Int(value * 100)
    }

    private func updateValueLabel(_ value: Int) {
        valueLabel.attributedText = StringUtils.attributedRatingString(for: value)
    }

}
