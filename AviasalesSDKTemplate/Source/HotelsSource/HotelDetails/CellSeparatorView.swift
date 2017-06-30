class CellSeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        backgroundColor = JRColorScheme.darkBackgroundColor()
    }

    class func preferredHeight() -> CGFloat {
        return UIView.onePixel
    }

}
