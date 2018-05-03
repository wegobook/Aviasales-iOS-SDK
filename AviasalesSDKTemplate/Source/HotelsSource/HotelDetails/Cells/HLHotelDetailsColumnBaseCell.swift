enum HLHotelDetailsColumnCellStyle: Int {
    case oneColumn
    case twoColumns
}

class HLHotelDetailsColumnBaseCell: HLHotelDetailsTableCell {

    var columnCellStyle: HLHotelDetailsColumnCellStyle = .oneColumn {
        didSet {
            self.updateCellStyle()
        }
    }

    @IBOutlet weak var firstTitleLabel: UILabel!

    class func fakeCellInstance() -> HLHotelDetailsColumnBaseCell {
        assertionFailure("Override in subclass")
        return HLHotelDetailsColumnBaseCell()
    }

    class func configureFakeCellInstance(_ fakeCellInstance: HLHotelDetailsColumnBaseCell, cellWidth: CGFloat) {
        fakeCellInstance.columnCellStyle = .twoColumns
        fakeCellInstance.bounds = CGRect(x: 0, y: 0, width: cellWidth, height: 44)
        fakeCellInstance.layoutIfNeeded()
    }

    class func canFillHalfScreen(_ text: String, cellWidth: CGFloat) -> Bool {

        let cell = fakeCellInstance()
        self.configureFakeCellInstance(cell, cellWidth: cellWidth)
        let label = cell.firstTitleLabel
        guard let labelFont = label?.font else {
            assertionFailure()
            return false
        }

        let attributes = [NSAttributedStringKey.font : labelFont]
        let textWidth = text.hl_width(attributes: attributes, height: (label?.frame.size.height)!)

        return textWidth < label!.frame.size.width
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.columnCellStyle = .oneColumn
    }

    func updateCellStyle() {
        // override in subclass
    }

}
