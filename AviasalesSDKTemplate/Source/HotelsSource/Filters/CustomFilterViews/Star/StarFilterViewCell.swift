import UIKit

@IBDesignable class StarFilterViewCell: RootFilterViewCell {

    @IBOutlet var firstStarTrailing: NSLayoutConstraint!
    @IBOutlet var secondStarTrailing: NSLayoutConstraint!
    @IBOutlet var thirdStarTrailing: NSLayoutConstraint!
    @IBOutlet var fourthStarTrailing: NSLayoutConstraint!
    @IBOutlet var fifthStarTrailing: NSLayoutConstraint!

    @IBOutlet var firstStarImageView: UIImageView!
    @IBOutlet var secondStarImageView: UIImageView!
    @IBOutlet var thirdStarImageView: UIImageView!
    @IBOutlet var fourthStarImageView: UIImageView!
    @IBOutlet var fifthStarImageView: UIImageView!

    override var selectedBackgroundColor: UIColor {
        return JRColorScheme.actionColor()
    }

    var starsImageViews: [UIImageView] {
        return [firstStarImageView, secondStarImageView, thirdStarImageView, fourthStarImageView, fifthStarImageView]
    }

    var starsTrailingConstraints: [NSLayoutConstraint] {
        return [firstStarTrailing, secondStarTrailing, thirdStarTrailing, fourthStarTrailing, fifthStarTrailing]
    }

    @IBInspectable var numberOfStars: Int = 0 {
        didSet {
            updateStars()
        }
    }

    override var isSelected: Bool {
        didSet {
            let starImageName = isSelected ? "FillFilterStar" : "EmptyFilterStar"
            let starImage = UIImage(named: starImageName, in: Bundle(for: type(of: self)), compatibleWith:nil)
            for imageView in starsImageViews {
                imageView.image = starImage
            }
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        isSelected = numberOfStars == 3 || numberOfStars == 4
    }

    // MARK: - Private

    private func updateStars() {
        guard firstStarTrailing != nil else { return }
        let starsTrailingConstraints = self.starsTrailingConstraints
        let indexToEnable = max(0, min(numberOfStars - 1, starsTrailingConstraints.count))

        NSLayoutConstraint.deactivate(starsTrailingConstraints)
        starsTrailingConstraints[indexToEnable].isActive = true
    }
}
