import UIKit

class RootFilterView: UIView, FilterViewCellDelegate {

    var tableWidth: CGFloat?
    private (set) var contentContainer: UIView!

    func nibName() -> String {
        return String(describing: type(of: self))
    }

    func allFilterCells() -> [RootFilterViewCell] {
        return []
    }

    private (set) var filter: Filter!

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

    private func initialize() {
        let view = loadViewFromNib(nibName(), self)!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        contentContainer = view
    }

    func configure(with filter: Filter) {
        self.filter = filter
        for i in 0..<allFilterCells().count {
            let cell = allFilterCells()[i]
            cell.isSelected = cellShouldBeSelected(cell: cell)
            cell.delegate = self
        }
    }

    func filterViewCellPressed(filterViewCell: RootFilterViewCell) {
        filterViewCell.isSelected = !filterViewCell.isSelected
    }

    func cellShouldBeSelected(cell: RootFilterViewCell) -> Bool {
        return false
    }

    class func height(for tableWidth: CGFloat, with filter: Filter) -> CGFloat {
        return 0
    }
}
