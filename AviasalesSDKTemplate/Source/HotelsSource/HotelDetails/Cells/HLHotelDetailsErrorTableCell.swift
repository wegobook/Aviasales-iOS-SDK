class HLHotelDetailsErrorTableCell: UITableViewCell {

    var buttonHandler: (() -> Void)!

    var hideTitle: Bool = false {
        didSet {
            self.centerButtonConstraint.constant = self.hideTitle ? 0.0 : -10.0
            self.titleLabel.isHidden = self.hideTitle
            self.icon.isHidden = self.hideTitle
        }
    }

    var hideButton: Bool = false {
        didSet {
            self.button.isHidden = self.hideButton
        }
    }

    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }

    var buttonText: String? {
        didSet {
            self.button.setTitle(self.buttonText, for: UIControlState())
        }
    }

    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var icon: UIImageView!
    @IBOutlet fileprivate weak var centerButtonConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Private methods

    fileprivate func initialize() {
        button.isHidden = hideButton
        button.setTitle(buttonText, for: .normal)
        button.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
        titleLabel.text = titleText
    }

    // MARK: - IBAction methods

    @IBAction private func onButton(_ sender: AnyObject?) {
        buttonHandler()
    }

}
