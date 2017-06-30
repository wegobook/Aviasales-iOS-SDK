let kNavBarHeight: CGFloat = 49.0

func loadViewFromNib(_ nibName: String, owner: AnyObject) -> UIView {
    let bundle = Bundle(for: type(of: owner))
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: owner, options: nil)[0] as! UIView

    return view
}
