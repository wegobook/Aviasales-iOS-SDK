class HLHotelDetailsBadgesCell: HLHotelDetailsTableCell {

    private static var cellInstance: HLHotelDetailsBadgesCell = {
            let views = Bundle.main.loadNibNamed("HLHotelDetailsBadgesCell", owner: nil, options: nil) as! [UIView]
            return views.first as! HLHotelDetailsBadgesCell
        }()

    var badges: [HLPopularHotelBadge]? {
        didSet {
            self.updateContent()
        }
    }

    @IBOutlet fileprivate(set) weak var iconView: UIImageView!

    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - Class methods

    class func estimatedHeight(_ badges: [HLPopularHotelBadge]?, width: CGFloat, first: Bool, last: Bool) -> CGFloat {

        let cell = cellInstance
        let cellWidthConstraint = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        cell.frame = CGRect(x: 0.0, y: 0.0, width: width, height: cell.bounds.height)
        cell.badges = badges
        cell.addConstraint(cellWidthConstraint)
        cell.topConstraint.constant = first ? 16.0 : 5.0
        cell.bottomConstraint.constant = last ? 16.0 : 5.0
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        let height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

        return ceil(height)
    }

    fileprivate class var badgeLabelHeight: CGFloat {
        return 20.0
    }

    // MARK: - Override methods

    override var first: Bool {
        didSet {
            self.topConstraint.constant = self.first ? 16.0 : 5.0

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override var last: Bool {
        didSet {
            self.bottomConstraint.constant = self.last ? 16.0 : 5.0

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.containerView.backgroundColor = UIColor.clear
    }

    // MARK: - Private methods

    fileprivate func createBadgeLabel(_ badge: HLPopularHotelBadge) -> UILabel {
        let widthLimit = self.containerView.bounds.width
        let label = HLBadgeLabel(frame: CGRect.zero)
        label.insets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.backgroundColor = badge.color
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.text = badge.name ?? ""
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.textColor = UIColor.white
        label.preferredMaxLayoutWidth = widthLimit

        let inset: CGFloat = label.insets.left + label.insets.right
        let height = HLHotelDetailsBadgesCell.badgeLabelHeight
        let size = label.sizeThatFits(CGSize(width: widthLimit, height: height))
        let width = (size.width + inset) > widthLimit ? widthLimit : (size.width + inset)
        label.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)

        return label
    }

    fileprivate func updateContent() {
        for view in containerView.subviews {
            view.removeFromSuperview()
        }

        guard let badges = self.badges else { return }

        for badge in badges {
            guard badge.name != nil else { continue }
            let label = createBadgeLabel(badge)
            containerView.addSubview(label)
        }

        let views = self.containerView.subviews
        let widthLimit = self.containerView.bounds.width
        let badgesContainerHeight = ceil(UIView.packViews(views, widthLimit: widthLimit, rowOffset: 5.0))

        for constraint in self.containerView.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = badgesContainerHeight
            }
        }
    }

}
