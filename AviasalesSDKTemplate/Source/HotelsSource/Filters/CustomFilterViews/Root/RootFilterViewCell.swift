import UIKit

@objc protocol FilterViewCellDelegate: NSObjectProtocol {
    func filterViewCellPressed(filterViewCell: RootFilterViewCell)
}

class RootFilterViewCell: UIControl {

    @IBOutlet weak var delegate: FilterViewCellDelegate?

    var selectedBackgroundColor: UIColor {
        return UIColor.gray
    }

    var defaultBackgroundColor: UIColor {
        return UIColor.white
    }

    var selectedBorderWidth: CGFloat {
        return 0
    }

    var defaultBorderWidth: CGFloat {
        return 2
    }

    var selectedBorderColor: CGColor {
        return UIColor.clear.cgColor
    }

    var defaultBorderColor: CGColor {
        return JRColorScheme.darkBackgroundColor().cgColor
    }

    @IBOutlet var contentContainer: UIView!

    @IBInspectable override var isSelected: Bool {
        didSet {
            contentContainer.backgroundColor = isSelected ? selectedBackgroundColor : defaultBackgroundColor
            contentContainer.layer.borderWidth = isSelected ? selectedBorderWidth : defaultBorderWidth
            contentContainer.layer.borderColor = isSelected ? selectedBorderColor : defaultBorderColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    func initialize() {
        let nibName = String(describing: type(of: self))
        let view = loadViewFromNib(nibName, self)!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        contentContainer = view

        addTarget(self, action: #selector(filterViewPressed), for: .touchUpInside)
    }

    @IBInspectable override var isHighlighted: Bool {
        didSet {
            contentContainer.alpha = isHighlighted ? 0.5 : 1.0
        }
    }

    @objc func filterViewPressed(_ sender: RootFilterViewCell) {
        delegate?.filterViewCellPressed(filterViewCell: self)
    }

    func configure(with item: StringFilterItem) {
    }

    class func rect(for item: StringFilterItem) -> CGRect {
        return CGRect.zero
    }

}
