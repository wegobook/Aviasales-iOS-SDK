import PureLayout

@objcMembers
class SeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = JRColorScheme.darkBackgroundColor()
    }

    init(color: UIColor) {
        super.init(frame: CGRect.zero)
        backgroundColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    func attachToView(_ targetView: UIView, edge: ALEdge) {
        attachToView(targetView, edge: edge, insets: UIEdgeInsets.zero)
    }

    func attachToView(_ targetView: UIView, edge: ALEdge, insets: UIEdgeInsets) {
        targetView.addSubview(self)
        setupConstraints(edge, insets: insets)
    }

    func attachBehindView(_ targetView: UIView, edge: ALEdge) {
        if let targetSuperview = targetView.superview {
            targetSuperview.addSubview(self)
            setupBehindConstraints(edge, to: targetView)
        } else {
            assertionFailure()
        }
    }

    private func setupBehindConstraints(_ edge: ALEdge, to view: UIView) {
        let edgesToPin: [(ALEdge, ALEdge)]
        let dimension: ALDimension
        switch edge {

        case .left:
            edgesToPin = [(.bottom, .bottom), (.top, .top), (.right, .left)]
            dimension = .width

        case .right:
            edgesToPin = [(.bottom, .bottom), (.top, .top), (.left, .right)]
            dimension = .width

        case .top:
            edgesToPin = [(.leading, .leading), (.trailing, .trailing), (.bottom, .top)]
            dimension = .height

        case .bottom:
            edgesToPin = [(.leading, .leading), (.trailing, .trailing), (.top, .bottom)]
            dimension = .height

        case .leading:
            edgesToPin = [(.bottom, .bottom), (.top, .top), (.trailing, .leading)]
            dimension = .width

        case .trailing:
            edgesToPin = [(.bottom, .bottom), (.top, .top), (.leading, .trailing)]
            dimension = .width
        }

        for edges in edgesToPin {
            autoPinEdge(edges.0, to: edges.1, of: view)
        }

        autoSetDimension(dimension, toSize: UIView.onePixel)
    }

    private func setupConstraints(_ edge: ALEdge, insets: UIEdgeInsets) {
        let excludedEdge: ALEdge
        let dimension: ALDimension
        switch edge {

        case .left:
            excludedEdge = .right
            dimension = .width

        case .right:
            excludedEdge = .left
            dimension = .width

        case .top:
            excludedEdge = .bottom
            dimension = .height

        case .bottom:
            excludedEdge = .top
            dimension = .height

        case .leading:
            excludedEdge = .trailing
            dimension = .width

        case .trailing:
            excludedEdge = .leading
            dimension = .width
        }
        autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: excludedEdge)
        autoSetDimension(dimension, toSize: UIView.onePixel)
    }

}
