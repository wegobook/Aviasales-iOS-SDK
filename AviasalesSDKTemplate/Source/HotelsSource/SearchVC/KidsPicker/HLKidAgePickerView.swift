import UIKit

protocol HLKidAgePickerViewDelegate: class, NSObjectProtocol {
    func didSelectAge(_ age: Int)
    func didCloseAgeSelector()
}

class HLKidAgePickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet fileprivate var pickerHeaderView: UIView!
    @IBOutlet fileprivate var agePickerView: UIPickerView!
    @IBOutlet fileprivate var applyButton: UIButton!
    @IBOutlet fileprivate var cancelButton: UIButton!
    @IBOutlet fileprivate var pickerBottomConstraint: NSLayoutConstraint!

    weak var delegate: HLKidAgePickerViewDelegate?

    var presented: Bool = false

    var kidAge: Int = 7 {
        didSet {
            self.agePickerView?.selectRow(self.kidAge, inComponent: 0, animated: false)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if pickerHeaderView.frame.contains(point) || agePickerView.frame.contains(point) {
            return super.point(inside: point, with: event)
        }
        hide(true)

        return false
    }

    // MARK: - Internal methods

    func show(_ onView: UIView, animated: Bool) {
        onView.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear

        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[selfView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selfView": self])
        onView.addConstraints(verticalConstraint)
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[selfView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selfView": self])
        onView.addConstraints(horizontalConstraint)
        onView.layoutIfNeeded()

        self.pickerBottomConstraint.constant = -(self.agePickerView.bounds.height + self.pickerHeaderView.bounds.height)
        self.layoutIfNeeded()

        let duration = (animated ? 0.4 : 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(),
            animations: { [weak self] () -> Void in
                self?.pickerBottomConstraint.constant = 0.0
                self?.layoutIfNeeded()
            },
            completion: { [weak self] (finished) -> Void in
                self?.presented = true
            })
    }

    func hide(_ animated: Bool) {
        self.delegate?.didCloseAgeSelector()

        let duration = (animated ? 0.4 : 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(),
            animations: { [weak self] () -> Void in
                let agePickerBounds = self?.agePickerView?.bounds ?? CGRect.zero
                let pickerHeaderBounds = self?.pickerHeaderView?.bounds ?? CGRect.zero

                self?.backgroundColor = UIColor.clear
                self?.pickerBottomConstraint.constant = -(agePickerBounds.height + pickerHeaderBounds.height)
                self?.layoutIfNeeded()
            },
            completion: { [weak self] (finished) -> Void in
                self?.removeFromSuperview()
                self?.presented = false
            })
    }

    // MARK: - Private methods

    fileprivate func initialize() {
        agePickerView?.showsSelectionIndicator = true
        agePickerView?.backgroundColor = UIColor.white
        agePickerView?.selectRow(kidAge, inComponent: 0, animated: false)

        let normalColor = JRColorScheme.mainButtonBackgroundColor()
        applyButton.setTitleColor(normalColor, for: UIControlState())
        cancelButton.setTitleColor(normalColor, for: UIControlState())
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)

        applyButton.setTitle(NSLS("HL_KIDS_PICKER_APPLY_BUTTON_TITLE"), for: .normal)
        cancelButton.setTitle(NSLS("HL_KIDS_PICKER_CANCEL_BUTTON_TITLE"), for: .normal)
    }

    // MARK: - IBActions methods

    @IBAction fileprivate func onApply(_ sender: AnyObject!) {
        self.delegate?.didSelectAge(self.agePickerView.selectedRow(inComponent: 0))
        self.hide(true)
    }

    @IBAction fileprivate func onCancel(_ sender: AnyObject!) {
        self.hide(true)
    }

    // MARK: - UIPickerViewDataSource methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 18
    }

    // MARK: - UIPickerViewDelegate methods

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row == 0) ? NSLS("HL_KIDS_PICKER_LESS_THAN_ONE_YEAR_TITLE") : "\(row)"
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel? = view as? UILabel
        if label == nil {
            label = UILabel()
        }

        label?.textAlignment = NSTextAlignment.center
        label?.textColor = UIColor.darkText
        label?.text = (row == 0) ? NSLS("HL_KIDS_PICKER_LESS_THAN_ONE_YEAR_TITLE") : "\(row)"

        return label!
    }

}
