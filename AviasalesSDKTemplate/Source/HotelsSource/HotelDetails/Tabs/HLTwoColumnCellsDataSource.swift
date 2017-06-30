import Foundation

typealias HLCanFillHalfScreen = (_ text: String, _ cellWidth: CGFloat) -> Bool

class HLTwoColumnCellsDataSource: NSObject {

    fileprivate let flattenedItems: [NamedHotelDetailsItem]
    fileprivate let cellWidth: CGFloat
    fileprivate let canFillHalfScreen: HLCanFillHalfScreen

    init(flattenedItems: [NamedHotelDetailsItem], cellWidth: CGFloat, canFillHalfScreen: @escaping HLCanFillHalfScreen) {
        self.flattenedItems = flattenedItems
        self.cellWidth = cellWidth
        self.canFillHalfScreen = canFillHalfScreen
        super.init()
    }

    func splitItemsRespectOrder(oneColumnAfterFirstLongItem: Bool = true) -> [TableItem] {
        var result: [TableItem] = []

        let (shortItemsArrayIndexSet, _) = type(of: self).calculateShortAndLongItemsIndices(flattenedItems.map { $0.name }, canFillHalfScreen: canFillHalfScreen, cellWidth: cellWidth)

        var currentItemIndex = 0
        while currentItemIndex < flattenedItems.count - 1 {
            if shortItemsArrayIndexSet.contains(currentItemIndex) && shortItemsArrayIndexSet.contains(currentItemIndex + 1) {
                let item = self.createPairWithItems(flattenedItems[currentItemIndex], secondItem:flattenedItems[currentItemIndex + 1])
                result.append(item)
                currentItemIndex += 2
            } else {
                result.append(flattenedItems[currentItemIndex])
                currentItemIndex += 1
                if oneColumnAfterFirstLongItem {
                    break
                }
            }
        }

        while currentItemIndex < flattenedItems.count {
            result.append(flattenedItems[currentItemIndex])
            currentItemIndex += 1
        }

        return result
    }

    func splitItemsLongAtBottom() -> [TableItem] {
        var result: [TableItem] = []

        let names = flattenedItems.map { $0.name }
        let (shortItemsIndexSet, longItemsIndexSet) = type(of: self).calculateShortAndLongItemsIndices(names, canFillHalfScreen: canFillHalfScreen, cellWidth: cellWidth)

        let shortItemsArray = flattenedItems.objectsAtIndexes(shortItemsIndexSet)
        result += splittedPairsFromShortItems(shortItemsArray)

        let longItemsArray = flattenedItems.objectsAtIndexes(longItemsIndexSet)
        result += longItemsArray.map { $0 as TableItem }

        return result
    }

    // MARK: - Help methods

    class func calculateShortAndLongItemsIndices(_ items: [String], canFillHalfScreen: HLCanFillHalfScreen, cellWidth: CGFloat) -> (shortItems: IndexSet, longItems: IndexSet) {
        let shortItemsArrayIndexSet = NSMutableIndexSet()
        let longItemsArrayIndexSet = NSMutableIndexSet()

        for (index, text) in items.enumerated() {
            if canFillHalfScreen(text, cellWidth) {
                shortItemsArrayIndexSet.add(index)
            } else {
                longItemsArrayIndexSet.add(index)
            }
        }

        return (shortItemsArrayIndexSet as IndexSet, longItemsArrayIndexSet as IndexSet)
    }

    fileprivate func splittedPairsFromShortItems(_ shortItemsArray: [TableItem]) -> [TableItem] {
        var pairsToReturn: [TableItem] = []

        for i in stride(from: 0, to: shortItemsArray.count, by: 2) {
            let firstItem = shortItemsArray[i]
            if i+1 < shortItemsArray.count {
                let secondItem = shortItemsArray[i+1]
                let cellItem = self.createPairWithItems(firstItem, secondItem: secondItem)
                pairsToReturn.append(cellItem)
            } else {
                pairsToReturn.append(firstItem)
            }
        }

        return pairsToReturn
    }

    private func createPairWithItems(_ firstItem: TableItem, secondItem: TableItem) -> TableItem {
        return NamedPairItem(firstItem: firstItem as! NamedHotelDetailsItem, secondItem: secondItem as? NamedHotelDetailsItem)
    }
}
