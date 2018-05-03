import UIKit

@objcMembers
class HLActionCardsArrayHelper: NSObject {

    class func addItem(_ itemToInsert: HLActionCardItem, toArray items: [HLCollectionItem], atIndex index: NSInteger, minVariantsCount: NSInteger) -> [HLCollectionItem] {
        return self.addItem(itemToInsert, toArray: items, atIndex: index, minVariantsCount: minVariantsCount, canAppend: false)
    }

    class func addItem(_ itemToInsert: HLActionCardItem, toArray items: [HLCollectionItem], atIndex index: NSInteger, minVariantsCount: NSInteger, canAppend: Bool) -> [HLCollectionItem] {
        var itemsCopy: [HLCollectionItem] = items

        if index == 0 && itemsCopy.count >= index {
            var indexToInsert = index
            while indexToInsert < itemsCopy.count && itemsCopy[indexToInsert] is HLActionCardItem {
                indexToInsert += 1
            }
            itemsCopy.insert(itemToInsert, at: indexToInsert)
        } else {
            var itemsHasEnoughVariants = false
            var indexToInsert: Int? = nil
            var variantsCount = 0
            var itemsReviewed = 0

            while !(itemsHasEnoughVariants && indexToInsert != nil) && itemsReviewed < items.count {
                let item = items[itemsReviewed]
                itemsReviewed += 1
                guard item is HLVariantItem else {continue}
                variantsCount += 1

                if variantsCount == index {
                    indexToInsert = itemsReviewed
                }

                if variantsCount >= minVariantsCount {
                    itemsHasEnoughVariants = true
                }
            }

            if itemsHasEnoughVariants {
                if indexToInsert == nil && canAppend {
                    indexToInsert = itemsCopy.count
                }
                if indexToInsert != nil {
                    itemsCopy.insert(itemToInsert, at: indexToInsert!)
                }
            }
        }

        return itemsCopy
    }
}
