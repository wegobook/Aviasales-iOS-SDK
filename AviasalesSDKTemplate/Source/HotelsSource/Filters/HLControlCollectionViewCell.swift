import UIKit

class HLControlCollectionViewCell: UICollectionViewCell {
	@IBOutlet fileprivate(set) weak var textLabel: UILabel!

    var textFont = UIFont.systemFont(ofSize: 12.0)
    var selectedTextFont = UIFont.systemFont(ofSize: 12.0)

    override func awakeFromNib() {
        super.awakeFromNib()

        textLabel.font = textFont
    }

    func setCustomSelected(_ selected: Bool) {
        if selected {
            textLabel.font = selectedTextFont
            textLabel.textColor = JRColorScheme.actionColor()
            textLabel.alpha = 1.0
        } else {
            textLabel.font = textFont
            textLabel.textColor = UIColor.darkText
            textLabel.alpha = 0.7
        }
    }

}
