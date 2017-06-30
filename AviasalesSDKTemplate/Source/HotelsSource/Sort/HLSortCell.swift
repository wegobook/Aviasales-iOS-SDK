class HLSortCell: SelectionFilterCell {

    override var checkboxOnImage: UIImage? {
        return UIImage(named:"sortActiveIcon")
    }

    override var checkboxOffImage: UIImage? {
        return nil
    }

    override var active: Bool {
        didSet {
            titleToAccessoryViewConstraint?.isActive = active
        }
    }
}
