import UIKit

class ScoreView: UIView {
    @IBOutlet weak var scoreLabel: UILabel?

    func update(withScore score: Int) {
        scoreLabel?.text = StringUtils.shortRatingString(score)
        self.backgroundColor = JRColorScheme.ratingColor(score)
    }
}
