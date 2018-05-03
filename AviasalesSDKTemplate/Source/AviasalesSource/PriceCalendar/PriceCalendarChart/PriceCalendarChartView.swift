//
//  PriceCalendarChartView.swift
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 10/06/15.
//  Copyright (c) 2015 aviasales. All rights reserved.
//

import UIKit

@objc
protocol PriceCalendarChartViewDelegate: NSObjectProtocol {
    func monthDidChangeInPriceCalendarChartView(_ chartView: PriceCalendarChartView)
}

private let barWidth: CGFloat = 55.0
private let kBarSpacing: CGFloat = 5
private let kPriceCalendarChartBarCellId = "PriceCalendarChartBarCell"
private let kInsetHeaderId = "insetHeader"
private let kInsetFooterId = "insetFooter"

@objcMembers
class PriceCalendarChartView: UIView {

    weak var delegate: PriceCalendarChartViewDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!

    var selectOnScroll = true
    var showPriceView = true {
        didSet {
            priceView?.isHidden = !showPriceView
        }
    }

    private var currentDate: Date?
    fileprivate var needAnimateBars = false
    fileprivate var priceView: PriceCalendarPriceView!
    fileprivate var currentCenterCellRow = 0
    private var priceLevelLineView: PriceCalendarPriceLevelView!
    private var priceLevelVerticalPositionConstraint: NSLayoutConstraint!
    fileprivate var departures = [JRSDKPriceCalendarDeparture]()
    private var prevSize = CGSize.zero
    fileprivate var numberOfOldDepartures = 0
    fileprivate var dataReloading = false

    override func awakeFromNib() {
        super.awakeFromNib()

        monthLabel?.textColor = JRColorScheme.lightTextColor()

        collectionView.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: kPriceCalendarChartBarCellId, bundle: nil), forCellWithReuseIdentifier: kPriceCalendarChartBarCellId)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kInsetHeaderId)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kInsetFooterId)

        NotificationCenter.default.addObserver(self, selector: #selector(PriceCalendarChartView.managerEndLoadingNotification(_:)), name: NSNotification.Name(rawValue: JRSDKPriceCalendarLoaderEndLoadingNotification), object: nil)

        priceView = PriceCalendarPriceView()
        addSubview(priceView)
        priceView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: priceView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: priceView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: -9.0))
        priceView.backgroundColor = UIColor.clear
        priceView?.isHidden = !showPriceView

        priceLevelLineView = PriceCalendarPriceLevelView()
        addSubview(priceLevelLineView)
        priceLevelLineView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: priceLevelLineView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: priceLevelLineView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: priceLevelLineView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: JRPixel()))
        priceLevelVerticalPositionConstraint = NSLayoutConstraint(item: priceLevelLineView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -29.0)
        addConstraint(priceLevelVerticalPositionConstraint)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if prevSize == .zero || bounds.size != prevSize {
            prevSize = bounds.size
            createDepartures()
            if let departure = PriceCalendarManager.shared.loader?.selectedDeparture {
                selectDeparture(departure, makeVisible: true)
            }
        }
    }

    fileprivate func createDepartures() {
        guard let loader = PriceCalendarManager.shared.loader else {
            return
        }

        numberOfOldDepartures = Int(ceil(bounds.width/(barWidth + kBarSpacing)/2))
        let allDepartures = loader.allDepartures!
        departures = Array(allDepartures[(Int(JRSDKPriceCalendarLoaderNumberOfOldDepartures)-numberOfOldDepartures)..<allDepartures.count])
        collectionView.reloadData()
        defineCenterCell()
    }

    func reloadData() {
        dataReloading = true
        layoutIfNeeded()
        createDepartures()

        if let selectedDeparture = PriceCalendarManager.shared.loader?.selectedDeparture {
            currentDate = selectedDeparture.date()
            scrollToDeparture(selectedDeparture, animated: false)
        }
    }

    fileprivate func scrollToDeparture(_ departure: JRSDKPriceCalendarDeparture, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let index = departures.index(of: departure) {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: animated)
        }

        //wait for scrolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion?()
        }
    }

    fileprivate func selectDeparture(_ departure: JRSDKPriceCalendarDeparture, makeVisible: Bool = false) {
        if let index = departures.index(of: departure) {
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: makeVisible ? .centeredHorizontally : UICollectionViewScrollPosition())
            defineCenterCell()
            priceView.setPriceCalendarDeparture(departure)
        }
    }

    fileprivate func setMonth() {
        if currentCenterCellRow < departures.count {
            let departure = departures[currentCenterCellRow]

            let monthText = DateUtil.monthName(departure.date()).capitalized

            if monthText != monthLabel.text {
                let animation = CATransition()
                animation.duration = 0.5
                animation.type = kCATransitionFade
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                monthLabel.layer.add(animation, forKey: "changeTextTransition")

                monthLabel.text = monthText

                delegate?.monthDidChangeInPriceCalendarChartView(self)
            }

            let levelCorrection = -PriceCalendarChartBarCell.barPadding + 2 * JRPixel() +  PriceCalendarChartBarCell.cornerRadius

            if let minPriceInMonth = PriceCalendarManager.shared.loader?.minPrice(inMonthOf: departure.date())?.floatValue, minPriceInMonth > 0 {

                let level = PriceCalendarChartBarCell.calculateHeight(for: minPriceInMonth, bounds: collectionView.bounds)

                let newLevel = -level + levelCorrection

                if priceLevelVerticalPositionConstraint.constant != newLevel {
                    updatePriceLineView(duration: 0.5, alpha: 1, constant: newLevel)
                }

            } else {
                updatePriceLineView(duration: 0.3, alpha: 0, constant: levelCorrection)
            }
        }
    }

    private func updatePriceLineView(duration: TimeInterval = 0, alpha: CGFloat, constant: CGFloat) {
        layoutIfNeeded()
        UIView.animate(withDuration: duration) { [weak self] in
            self?.priceLevelLineView.alpha = alpha
            self?.priceLevelVerticalPositionConstraint.constant = constant
            self?.layoutIfNeeded()
        }
    }

    func selectCurrentCenterCell() {
        guard selectOnScroll else {
            return
        }
        collectionView.selectItem(at: IndexPath(item: currentCenterCellRow, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        if currentCenterCellRow < departures.count {
            let departure = departures[currentCenterCellRow]
            if let selectedDeparture = PriceCalendarManager.shared.loader?.selectedDeparture, selectedDeparture.date() != departure.date() {
                PriceCalendarManager.shared.loader?.selectDepartureDate(departure.date(), initialSelect: false)
                selectDeparture(selectedDeparture)
            }
            priceView.setPriceCalendarDeparture(departure)
        }
    }

    fileprivate func defineCenterCell() {
        let scrollView = collectionView as UIScrollView
        let centerPoint = CGPoint(x: collectionView.frame.size.width/2 + scrollView.contentOffset.x, y: collectionView.frame.size.height/2 + scrollView.contentOffset.y)
        if let centerCellIndexPath = collectionView.indexPathForItem(at: centerPoint) {
            if currentCenterCellRow != centerCellIndexPath.row {
                currentCenterCellRow = max(centerCellIndexPath.row, numberOfOldDepartures)
                if centerCellIndexPath.row < departures.count {
                    let departure = departures[centerCellIndexPath.row]
                    priceView?.setPriceCalendarDeparture(departure)
                    currentDate = departure.date()
                }
            }
            setMonth()
        }
    }
}

extension PriceCalendarChartView {

    @objc func managerEndLoadingNotification(_ notification: Notification) {

        needAnimateBars = dataReloading ? dataReloading : needAnimateBars

        createDepartures()

        if let selectedDeparture = PriceCalendarManager.shared.loader?.selectedDeparture {
            selectDeparture(selectedDeparture)
        }

        setMonth()
    }
}

extension PriceCalendarChartView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return departures.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPriceCalendarChartBarCellId, for: indexPath) as UICollectionViewCell
        if let cell = cell as? PriceCalendarChartBarCell {
            if indexPath.row < departures.count {
                let departure = departures[indexPath.row]
                cell.setDeparture(departure, animated: needAnimateBars)
                cell.isUserInteractionEnabled = !departure.isOld()
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kInsetHeaderId, for: indexPath) as UICollectionReusableView
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kInsetFooterId, for: indexPath) as UICollectionReusableView
        }
    }
}

extension PriceCalendarChartView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: barWidth, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kBarSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let diff: CGFloat = collectionView.bounds.width/2 - CGFloat(numberOfOldDepartures)*(barWidth+kBarSpacing) - barWidth/2
        return CGSize(width: diff, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - barWidth/2, height: 0)
    }
}

extension PriceCalendarChartView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < departures.count {
            needAnimateBars = false
            dataReloading = false

            let departure = departures[indexPath.row]

            if let selectedDeparture = PriceCalendarManager.shared.loader?.selectedDeparture, departure == selectedDeparture {
                return
            }

            scrollToDeparture(departure) {
                PriceCalendarManager.shared.loader?.selectDepartureDate(departure.date(), initialSelect: false)
            }
        }
    }
}

extension PriceCalendarChartView: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        needAnimateBars = false
        dataReloading = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defineCenterCell()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let deceleratingCellCount = Int(ceil(velocity.x))*3
        var targetX: CGFloat = 0
        var targetRow = 0

        if velocity.x == 0 {
            targetRow = currentCenterCellRow
        } else if velocity.x > 0 {
            targetRow = currentCenterCellRow + deceleratingCellCount + 1
            if targetRow >= collectionView.numberOfItems(inSection: 0) {
                targetRow = collectionView.numberOfItems(inSection: 0) - 1
            }
        } else if velocity.x < 0 {
            targetRow = currentCenterCellRow + deceleratingCellCount - 1
            if targetRow < 0 {
                targetRow = 0
            }
        }

        if let currentCellAttrs = collectionView.layoutAttributesForItem(at: IndexPath(item: targetRow, section: 0)) {
            targetX = currentCellAttrs.frame.origin.x - collectionView.frame.width/2 + barWidth/2 - JRPixel()
        }

        targetContentOffset.pointee = CGPoint(x: targetX, y: 0)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectCurrentCenterCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectCurrentCenterCell()
    }
}
