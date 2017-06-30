import Foundation

class HLProfileSelectableCell: SelectionFilterCell, HLProfileCellProtocol {

    func setup(with item: HLProfileTableItem) {
        active = item.active
        titleLabel.text = item.title
        accessibilityIdentifier = item.accessibilityIdentifier
    }
}
