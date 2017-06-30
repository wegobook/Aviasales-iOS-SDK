import UIKit

enum HLKidsPickerTableCellState {
    case disabled
    case ready
    case selected
}

class HLKidsPickerTableCell: UITableViewCell {

    var deleteCellHandler:((_ cell: HLKidsPickerTableCell) -> Void)?
    var willBeginEditingCellHandler:((_ cell: HLKidsPickerTableCell) -> Void)?
    var didEndEditingCellHandler:((_ cell: HLKidsPickerTableCell) -> Void)?
    var kidNumber: Int = 1 {
        didSet {
            self.kidCountLabel?.text = "\(kidNumber)"
        }
    }
    var kidAge: Int = 0 {
        didSet {
            self.updateControl()
        }
    }
    var state: HLKidsPickerTableCellState = HLKidsPickerTableCellState.ready {
        didSet {
            self.updateControl()
        }
    }

    lazy private var panGestureRecognizer: HLPanGestureRecognizer = { [unowned self] in
        let recognizer = HLPanGestureRecognizer(target: self, action: #selector(HLKidsPickerTableCell.onPan(_:)))
        recognizer.direction = HLPanGestureRecognizerDirectionHorizontal

        return recognizer
    }()

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var kidCountLabel: UILabel!
    @IBOutlet fileprivate weak var kidCountIcon: UIImageView!
    @IBOutlet fileprivate weak var disclosureIcon: UIImageView!
    @IBOutlet fileprivate weak var rightDeleteButtonConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var leftKidCountIconConstraint: NSLayoutConstraint!

    @IBOutlet weak var deleteButton: UIButton!

    private let disclosureImage = UIImage(named: "cellDisclosureIcon")!.imageTinted(with: JRColorScheme.mainButtonBackgroundColor())
    private let disclosureImageDisabled = UIImage(named: "cellDisclosureIcon")!

    private let kidCountImage = UIImage(named: "searchFormButton")!
    private let kidCountImageSelected = UIImage(named: "searchFormButtonSelected")!.imageTinted(with: JRColorScheme.mainButtonBackgroundColor())
    private let kidCountImageDisabled = UIImage(named: "searchFormButton")!.imageTinted(with: JRColorScheme.lightBackgroundColor())

    private let kKidCountIconLeftConstraint: CGFloat = 20.0
    private let kDeleteButtonRightConstraint: CGFloat = -80.0

    // MARK: - Override methods

    override func awakeFromNib() {
        super.awakeFromNib()
        kidCountIcon.highlightedImage = UIImage(named: "searchFormButton")!.imageTinted(with: JRColorScheme.mainBackgroundColor())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if isEditing || state == HLKidsPickerTableCellState.disabled {
            return
        }

        super.setSelected(selected, animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if isEditing || state == HLKidsPickerTableCellState.disabled {
            hideDeleteButton(true)
            return
        }

        super.setHighlighted(highlighted, animated: animated)

        disclosureIcon.isHighlighted = highlighted
        titleLabel.isHighlighted = highlighted
        kidCountLabel.isHighlighted = highlighted
        kidCountIcon.isHighlighted = highlighted
    }

    // MARK: - Public methods

    func showDeleteButton(_ animated: Bool) {
        if isEditing {
            return
        }

        willBeginEditingCellHandler?(self)

        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [unowned self] () -> Void in
            self.rightDeleteButtonConstraint.constant = 0.0
            self.leftKidCountIconConstraint.constant = self.kKidCountIconLeftConstraint + self.kDeleteButtonRightConstraint
            self.layoutIfNeeded()
            }, completion: { [unowned self] (finished) -> Void in
                self.isEditing = true
        })
    }

    func hideDeleteButton(_ animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [unowned self] () -> Void in
            self.rightDeleteButtonConstraint.constant = self.kDeleteButtonRightConstraint
            self.leftKidCountIconConstraint.constant = self.kKidCountIconLeftConstraint
            self.layoutIfNeeded()
            }, completion: { [unowned self] (finished) -> Void in
                self.didEndEditingCellHandler?(self)
                self.isEditing = false
        })
    }

    // MARK: - Private methods

    private func updateControl() {
        switch state {
        case HLKidsPickerTableCellState.disabled:
            disclosureIcon?.image = disclosureImageDisabled
            kidCountIcon.image = kidCountImageDisabled
            titleLabel?.text = NSLS("HL_KIDS_PICKER_CELL_SELECT_AGE_TITLE")
            titleLabel?.textColor = JRColorScheme.inactiveLightTextColor()
            kidCountLabel?.textColor = JRColorScheme.inactiveLightTextColor()

            removeGestureRecognizer(panGestureRecognizer)
            isUserInteractionEnabled = false

        case HLKidsPickerTableCellState.ready:
            disclosureIcon?.image = disclosureImage
            kidCountIcon.image = kidCountImage

            titleLabel?.text = NSLS("HL_KIDS_PICKER_CELL_SELECT_AGE_TITLE")
            titleLabel?.textColor = JRColorScheme.darkTextColor()
            kidCountLabel?.textColor = JRColorScheme.darkTextColor()

            removeGestureRecognizer(panGestureRecognizer)
            isUserInteractionEnabled = true

        case HLKidsPickerTableCellState.selected:
            disclosureIcon?.image = disclosureImage
            kidCountIcon.image = kidCountImageSelected

            titleLabel.text = StringUtils.kidAgeText(withAge: kidAge)
            titleLabel.textColor = JRColorScheme.darkTextColor()
            kidCountLabel.textColor = UIColor.white

            addGestureRecognizer(panGestureRecognizer)
            isUserInteractionEnabled = true
        }
    }

    @objc private func onPan(_ gestureRecognizer: HLPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocity(in: self)
        let translation = gestureRecognizer.translation(in: self)
        let startRightPosition = isEditing ? 0.0 : kDeleteButtonRightConstraint

        var constraint = startRightPosition - translation.x
        constraint = max(min(constraint, 0.0), kDeleteButtonRightConstraint)

        switch gestureRecognizer.state {
        case UIGestureRecognizerState.changed:
            rightDeleteButtonConstraint.constant = constraint
            leftKidCountIconConstraint.constant = kDeleteButtonRightConstraint + kKidCountIconLeftConstraint - constraint
            layoutIfNeeded()

        case UIGestureRecognizerState.ended:
            velocity.x < 0 ? showDeleteButton(true) : hideDeleteButton(true)

        case UIGestureRecognizerState.cancelled:
             hideDeleteButton(true)

        default:
            break
        }
    }

    // MARK: - IBActions methods

    @IBAction func onDelete(_ sender: AnyObject) {
        deleteCellHandler?(self)
    }

}
