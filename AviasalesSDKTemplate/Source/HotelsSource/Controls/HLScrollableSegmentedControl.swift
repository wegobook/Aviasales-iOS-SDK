import UIKit

protocol HLScrollableSegmentedControlDelegate: class, NSObjectProtocol {

    func selectedIndexDidChange(_ index: Int, animated: Bool)

}

@IBDesignable class HLScrollableSegmentedControl: UIView {

    var selectedIndex: Int {
        return currentIndex
    }

    var items: [String] = [] {
        didSet {
            guard view != nil else { return }

            reloadSegments()
        }
    }

    var contentOffset: CGPoint = CGPoint.zero {
        didSet {
            guard view != nil else { return }

            segmentsCollectionView.contentOffset.x = contentOffset.x
        }
    }

    var textFont = UIFont.systemFont(ofSize: 14.0) //appMediumFont(withSize: 14.0)
    var selectedTextFont = UIFont.systemFont(ofSize: 14.0) //UIFont.appMediumFont(withSize: 14.0)

    var alignTabsToCenter: Bool = false
    weak var scrollDelegate: HLScrollableSegmentedControlDelegate?

    @IBOutlet fileprivate weak var selectionView: UIImageView!
    @IBOutlet fileprivate weak var segmentsCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var selectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var selectionViewCenterConstraint: NSLayoutConstraint!

    fileprivate let cellInset: CGFloat = 8.0
    fileprivate var view: UIView!
    fileprivate var currentIndex: Int = 0
    fileprivate var cellSizes: [CGSize] = []

    // MARK: - Override methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var bounds: CGRect {
        didSet {
            guard view != nil else { return }

            if !bounds.size.equalTo(oldValue.size) {
                relayout()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        loadFromXib()
    }

    // MARK: - Internal methods

    func setSelectedIndex(_ index: Int, animated: Bool) {
        if currentIndex != index {
            applySelection(index, animated: animated)

            currentIndex = index

            scrollDelegate?.selectedIndexDidChange(index, animated: animated)
        }
    }

    func reloadSegments() {
        segmentsCollectionView.reloadData()

        relayout()
    }

    func relayout() {

        if selectedIndex >= items.count {
            currentIndex = 0
        }

        let oldScrollDelegate = scrollDelegate
        scrollDelegate = nil

        cellSizes = calculateCellSizes()
        let contentSize = calculateContentSize()
        segmentsCollectionView.collectionViewLayout.invalidateLayout()
        segmentsCollectionView.delegate = nil
        segmentsCollectionView.contentSize = contentSize
        segmentsCollectionView.delegate = self
        segmentsCollectionView.contentInset = calculateContentInsets()

        applySelection(selectedIndex, animated: false)

        scrollDelegate = oldScrollDelegate
    }

    // MARK: - Private methods

    fileprivate func loadFromXib() {
//        view = loadViewFromNib("HLScrollableSegmentedControl", owner: self)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.clear
//        view.frame = bounds
//
//        addSubview(view)
//
//        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
//        addConstraints(verticalConstraint)
//        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
//        addConstraints(horizontalConstraint)
//        setNeedsLayout()
//        layoutIfNeeded()
//
//        initialize()
    }

    fileprivate func initialize() {
        let cellNib = UINib(nibName: "HLControlCollectionViewCell", bundle: nil)
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = 0
        segmentsCollectionView.delegate = self
        segmentsCollectionView.dataSource = self
        segmentsCollectionView.register(cellNib, forCellWithReuseIdentifier: "HLControlCollectionViewCell")
        segmentsCollectionView.accessibilityIdentifier = "HLScrollableSegmentedControlCollectionView"

//        selectionView.image = UIImage(color: ColorScheme.current.mainAppColor, size: CGSize(width: 2.0, height: 2.0))
    }

    fileprivate func calculateContentSize() -> CGSize {
        var totalWidth: CGFloat = 0.0
        for size in cellSizes {
            totalWidth += size.width
        }

        totalWidth = iPad() ? max(totalWidth, bounds.width) : totalWidth

        return CGSize(width: totalWidth, height: bounds.height)
    }

    fileprivate func calculateCellSizes() -> [CGSize] {
        var sizes: [CGSize] = []
        for title in items {
            let attributes = [NSFontAttributeName: selectedTextFont]
            let width = title.hl_width(attributes: attributes, height: bounds.height) + cellInset * 2.0
            let size = CGSize(width: width, height: bounds.height)
            sizes.append(size)
        }

        return sizes
    }

    fileprivate func calculateContentInsets() -> UIEdgeInsets {
        var totalWidth: CGFloat = 0.0
        for size in cellSizes {
            totalWidth += size.width
        }

        let diff = (bounds.width - 2.0 * cellInset) - totalWidth
        let inset = alignTabsToCenter ? max(cellInset, ceil(diff / 2.0)) : cellInset

        return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }

    fileprivate func deselectCells() {
        for cell in segmentsCollectionView.visibleCells {
            if let c = cell as? HLControlCollectionViewCell {
                c.setCustomSelected(false)
            }
        }
    }

    fileprivate func applySelection(_ index: Int, animated: Bool) {
        deselectCells()

        let section = 0
        let indexPath = IndexPath(item: index, section: section)
        guard segmentsCollectionView.numberOfSections > section && index < segmentsCollectionView.numberOfItems(inSection: section) else { return }

        segmentsCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: animated)
        if let cell = segmentsCollectionView.cellForItem(at: indexPath) as? HLControlCollectionViewCell {
            cell.setCustomSelected(true)
        }
        segmentsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        updateSelectionViewWithIndex(index, animated: true)
    }

    fileprivate func updateSelectionViewWithIndex(_ index: Int, animated: Bool) {
        guard index < items.count else { return }

        let duration = animated ? 0.2 : 0.0
        let attributes = [NSFontAttributeName: selectedTextFont]
        let title = items[index]
        let width = title.hl_width(attributes: attributes, height: bounds.height) + cellInset * 2.0
        let indexPath = IndexPath(item: index, section: 0)
        let layoutAttributes = segmentsCollectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)
        let center = layoutAttributes?.center ?? CGPoint.zero
        let x = segmentsCollectionView.convert(center, to: self).x

        selectionViewCenterConstraint.constant = bounds.midX - x
        selectionViewWidthConstraint.constant = width

        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState,
            animations: { () -> Void in
                self.selectionView.setNeedsLayout()
                self.selectionView.layoutIfNeeded()
            }, completion: nil)
    }

}

extension HLScrollableSegmentedControl: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selected = (indexPath as NSIndexPath).item == currentIndex
        let cell = segmentsCollectionView.dequeueReusableCell(withReuseIdentifier: "HLControlCollectionViewCell", for: indexPath) as! HLControlCollectionViewCell
        cell.textFont = textFont
        cell.selectedTextFont = selectedTextFont
        cell.textLabel.text = items[(indexPath as NSIndexPath).row] as String
        cell.setCustomSelected(selected)

        if selected {
            updateSelectionViewWithIndex((indexPath as NSIndexPath).item, animated: false)
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return cellSizes[(indexPath as NSIndexPath).item]
    }

}

extension HLScrollableSegmentedControl: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setSelectedIndex((indexPath as NSIndexPath).item, animated: true)
    }

}

extension HLScrollableSegmentedControl: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectionViewWithIndex(currentIndex, animated: false)
    }

}
