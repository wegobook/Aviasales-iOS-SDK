class HLHotelDetailsTableCell: HLTableViewCell {

    @IBOutlet weak var leftContentOffset: NSLayoutConstraint?
    @IBOutlet weak var rightContentOffset: NSLayoutConstraint?
    let separatorView = SeparatorView()

    let contentHorizontalOffset: CGFloat = 15.0

    override var last: Bool {
        didSet {
            separatorView.isHidden = !last
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        self.backgroundColor = UIColor.white
        if let left = self.leftContentOffset, let right = self.rightContentOffset {
            left.constant = self.contentHorizontalOffset
            right.constant = self.contentHorizontalOffset
        }

        separatorView.isHidden = true
        separatorView.attachToView(self, edge: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }
}
