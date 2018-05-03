import Foundation

private enum BadgeType: Int {
    case ratingBadge
    case hotelBadge
    case discountBadge
    case distanceBadge
}

extension UIView {

    fileprivate class var badgeLabelHeight: CGFloat {
        return 22.0
    }

    fileprivate class var layerTagKey: String {
        return "layerTagKey"
    }

    class var onePixel: CGFloat {
        return 1.0 / UIScreen.main.scale
    }

    class func packRects(_ rects: [CGRect], widthLimit: CGFloat, rowOffset: CGFloat) -> CGFloat {
        return self.packRects(rects, widthLimit: widthLimit, rowOffset: rowOffset, horizontalOffset: rowOffset)
    }

    class func packRects(_ rects: [CGRect], widthLimit: CGFloat, rowOffset: CGFloat, horizontalOffset: CGFloat) -> CGFloat {
        return self.packRects(rects, widthLimit: widthLimit, rowOffset: rowOffset, horizontalOffset: horizontalOffset, shouldSort: true)
    }

    class func packRects(_ rects: [CGRect], widthLimit: CGFloat, rowOffset: CGFloat, horizontalOffset: CGFloat, shouldSort: Bool) -> CGFloat {
        if rects.count == 0 {
            return 0.0
        }

        let sortedRects = shouldSort ? rects.sorted { $0.width < $1.width } : rects

        let height = rects.first!.height
        var point = CGPoint.zero
        var rows = 0

        for rect in sortedRects {
            var currentHorizontalOffset = point.x == 0.0 ? 0.0 : horizontalOffset
            let rectWidth = min(rect.width, widthLimit)
            let offsetToCompare = point.x == 0 ? 0 : currentHorizontalOffset
            if (point.x + rectWidth + offsetToCompare) > widthLimit {
                currentHorizontalOffset = 0.0
                point.x = 0.0
                rows += 1
                point.y = CGFloat(rows) * (height + rowOffset)
            }

            point.x += rectWidth + currentHorizontalOffset
        }

        return height * CGFloat(rows + 1) + rowOffset * CGFloat(rows)
    }

    class func packViews(_ views: [UIView], widthLimit: CGFloat, rowOffset: CGFloat) -> CGFloat {
        return self.packViews(views, widthLimit: widthLimit, rowOffset: rowOffset, horizontalOffset: rowOffset)
    }

    @discardableResult
    class func packViews(_ views: [UIView], widthLimit: CGFloat, rowOffset: CGFloat, horizontalOffset: CGFloat, shouldSort: Bool = true) -> CGFloat {
        if views.count == 0 {
            return 0.0
        }

        let sortedViews = shouldSort ? views.sorted { $0.frame.width < $1.frame.width } : views

        let height = views.first!.bounds.height
        var point = CGPoint.zero
        var rows = 0

        for view in sortedViews {
            var currentHorizontalOffset = point.x == 0.0 ? 0.0 : horizontalOffset
            let viewWidth = min(view.frame.width, widthLimit)
            let offsetToCompare = point.x == 0 ? 0 : currentHorizontalOffset
            if (point.x + viewWidth + offsetToCompare) > widthLimit {
                currentHorizontalOffset = 0.0
                point.x = 0.0
                rows += 1
                point.y = 0.0 + CGFloat(rows) * (height + rowOffset)
            }

            point.x += currentHorizontalOffset
            view.frame = CGRect(x: point.x, y: point.y, width: viewWidth, height: view.frame.height)
            point.x += view.frame.width
        }

        return height * CGFloat(rows + 1) + rowOffset * CGFloat(rows)
    }

}

// MARK: - Draw primitives

extension UIView {

    func drawLine(_ fromPoint: CGPoint, toPoint: CGPoint, width: CGFloat, color: UIColor, tag: String) {
        var line: CAShapeLayer!
        if let sublayer = self.sublayer(tag) as? CAShapeLayer {
            line = sublayer
        } else {
            line = CAShapeLayer()
            line.setValue(tag, forKey: UIView.layerTagKey)
            self.layer.addSublayer(line)
        }

        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        path.lineWidth = width

        line.needsDisplayOnBoundsChange = true
        line.contentsScale = UIScreen.main.scale
        line.backgroundColor = color.cgColor

        var w = toPoint.x - fromPoint.x
        w = (w == 0) ? width : w
        var h = toPoint.y - fromPoint.y
        h = (h == 0) ? width : h

        line.frame = CGRect(x: fromPoint.x, y: fromPoint.y, width: w, height: h)
    }

    func sublayer(_ layerTag: String) -> CALayer? {
        if let sublayers = self.layer.sublayers {
            for sublayer in sublayers {
                let value = sublayer.value(forKey: UIView.layerTagKey) as? String
                if value == layerTag {
                    return sublayer
                }
            }
        }

        return nil
    }

}

// MARK: - Draw stars

@objc extension UIView {

    func drawYellowStars(_ count: Int, fromPoint: CGPoint, offset: CGFloat) {
        drawStars(count, fromPoint: fromPoint, fullImage: UIImage.yellowStar, emptyImage: UIImage.yellowStarEmpty, offset: offset)
    }

    func drawWhiteStars(_ count: Int, fromPoint: CGPoint, offset: CGFloat) {
        drawStars(count, fromPoint: fromPoint, fullImage: UIImage.whiteStar, emptyImage: UIImage.whiteStarEmpty, offset: offset)
    }

    func drawSmallWhiteStars(_ count: Int, fromPoint: CGPoint, offset: CGFloat) {
        drawStars(count, fromPoint: fromPoint, fullImage: UIImage.smallWhiteStar, emptyImage: UIImage.smallWhiteStarEmpty, offset: offset)
    }

    func drawStars(_ count: Int, fromPoint: CGPoint, image: UIImage, offset: CGFloat) {
        drawStars(count, fromPoint: fromPoint, fullImage: image, emptyImage: nil, offset: offset)
    }

    func drawStars(_ count: Int, fromPoint: CGPoint, fullImage: UIImage, emptyImage: UIImage?, offset: CGFloat) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        var stars: [UIView] = []
        for i in 0..<5 {
            let full = i < count
            let image: UIImage! = full || emptyImage == nil ? fullImage : emptyImage
            let imageView = UIImageView(image: image)
            imageView.alpha = (full || emptyImage != nil ? 1.0 : 0.4)
            stars.append(imageView)
            addSubview(imageView)

            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        }
        (stars as NSArray).autoDistributeViews(along: .horizontal, alignedTo: .horizontal, withFixedSpacing: offset, insetSpacing: false)
    }

    // MARK: - Private methods

    fileprivate func drawStar(_ inFrame: CGRect, image: UIImage, alpha: Float, tag: String) {
        var star: CAShapeLayer!

        if let sublayer = self.sublayer(tag) as? CAShapeLayer {
            star = sublayer
        } else {
            star = CAShapeLayer()
            star.setValue(tag, forKey: UIView.layerTagKey)
            self.layer.addSublayer(star)
        }

        star.contentsScale = UIView.onePixel
        star.frame = inFrame
        star.opacity = alpha
        star.contents = image.cgImage
    }
}

// MARK: - Draw Badges

@objc extension UIView {

    func removeTextBadges() {
        for view in self.subviews {
            if let v = view as? HLBadgeLabel {
                v.removeFromSuperview()
            }
            if let v = view as? HLBadgeIconView {
                v.removeFromSuperview()
            }
            if let v = view as? HLBadgeView {
                v.removeFromSuperview()
            }
        }
    }

    private func textbadgeLabel(with badge: HLPopularHotelBadge, widthLimit: CGFloat) -> HLBadgeLabel {
        let label = badgeLabel(widthLimit: widthLimit)
        label.text = badge.name ?? ""
        label.backgroundColor = badge.color
        updateSize(for: label, widthLimit: widthLimit)
        label.tag = BadgeType.hotelBadge.rawValue

        return label
    }

    private func ratingLabel(forBadge badge: HLRatingBadge, widthLimit: CGFloat) -> HLBadgeLabel {
        let label = badgeLabel(widthLimit: widthLimit)
        label.backgroundColor = badge.color
        label.attributedText = badge.ratingText
        updateSize(for: label, widthLimit: widthLimit)
        label.tag = BadgeType.ratingBadge.rawValue

        return label
    }

    private func badgeLabel(widthLimit: CGFloat) -> HLBadgeLabel {
        let label = HLBadgeLabel(frame: CGRect.zero)
        label.insets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        label.textColor = UIColor.white

        return label
    }

    private func updateSize(for label: HLBadgeLabel, widthLimit: CGFloat) {
        let inset: CGFloat = label.insets.left + label.insets.right
        let height = UIView.badgeLabelHeight
        let size = label.sizeThatFits(CGSize(width: widthLimit, height: height))
        let width = (size.width + inset) > widthLimit ? widthLimit : (size.width + inset)
        label.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
    }

    private func iconBadgeView(with badge: HLIconBadge) -> HLBadgeIconView {
        let view = loadViewFromNibNamed("HLBadgeIconView") as! HLBadgeIconView
        view.backgroundColor = badge.color
        let imageName = badge.imageName ?? ""
        view.image = UIImage(named: imageName)
        view.layer.cornerRadius = 1.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let dimension = UIView.badgeLabelHeight
        view.frame = CGRect(x: 0.0, y: 0.0, width: dimension, height: dimension)

        return view
    }

    private func distanceBadgeView(with badge: HLDistanceBadge) -> HLDistanceBadgeView {
        let badgeView = HLDistanceBadgeView.badgeView()
        badgeView.configure(for: badge.distance, pointType: badge.pointType)
        badgeView.frame.size = badgeView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return badgeView
    }

    func badgeView(for badge: HLPopularHotelBadge, variant: HLResultVariant?, widthLimit: CGFloat) -> UIView? {
        if let textBadge = badge as? HLTextBadge {
            return textbadgeLabel(with: textBadge, widthLimit: widthLimit)
        }

        if let iconBadge = badge as? HLIconBadge {
            return iconBadgeView(with: iconBadge)
        }

        if let distanceBadge = badge as? HLDistanceBadge {
            return distanceBadgeView(with: distanceBadge)
        }

        if let discountBadge = badge as? HLDiscountHotelBadge {
            return textbadgeLabel(with: discountBadge, widthLimit: widthLimit)
        }

        if let ratingBadge = badge as? HLRatingBadge {
            return ratingLabel(forBadge: ratingBadge, widthLimit: widthLimit)
        }

        return nil
    }

    @discardableResult
    func drawTextBadges(_ badges: [HLPopularHotelBadge], widthLimit: CGFloat, startOrigin: CGPoint) -> [UIView] {
        return drawTextBadges(badges, forVariant: nil, widthLimit: widthLimit, startOrigin: startOrigin)
    }

    @discardableResult
    func drawTextBadges(_ badges: [HLPopularHotelBadge], forVariant: HLResultVariant?, widthLimit: CGFloat, startOrigin: CGPoint) -> [UIView] {
        self.removeTextBadges()
        guard badges.count > 0 else { return [] }

        var views: [UIView] = []

        for badge in badges {
            guard let view = badgeView(for: badge, variant: forVariant, widthLimit: widthLimit) else { continue }
            views.append(view)
            addSubview(view)
        }
        guard views.count > 0 else { return [] }

        let height = views.first!.bounds.height
        var point = startOrigin
        var rows = 0

        views.sort { (first, second) -> Bool in
            if let distanceBadge = first as? HLDistanceBadgeView ?? second as? HLDistanceBadgeView {
                return distanceBadge == second
            }
            return first.frame.width < second.frame.width
        }

        for view in views {
            if (point.x + view.frame.width) > widthLimit {
                point.x = startOrigin.x
                rows += 1
                point.y = startOrigin.y + CGFloat(rows) * (height + 5.0)
            }

            view.frame = CGRect(x: point.x, y: point.y, width: view.frame.width, height: 24)
            view.setNeedsLayout()
            view.layoutIfNeeded()

            point.x += view.frame.width + 5.0
        }

        return views
    }

    @discardableResult
    func drawTextBadges(_ badges: [HLPopularHotelBadge], forVariant variant: HLResultVariant?, startX: CGFloat, bottomY: CGFloat, widthLimit: CGFloat) -> [UIView] {
        let views = drawTextBadges(badges, forVariant: variant, widthLimit: widthLimit, startOrigin: CGPoint(x: startX, y: 0.0))
        guard views.count > 0 else { return [] }
        let currentBottomY = views.last!.frame.origin.y + views.last!.frame.size.height
        let yDiff = bottomY - currentBottomY

        for badgeView in views {
            badgeView.frame.origin.y += yDiff
        }

        return views
    }
}
