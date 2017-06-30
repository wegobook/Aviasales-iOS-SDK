class HotellookSortItemsFactory: SortItemsFactory {

    override func sortTypesForFilter(_ filter: Filter) -> [SortType] {
        var items = super.sortTypesForFilter(filter)

        let index = min(items.count, 1)
        items.insert(.rating, at: index)

        let discountVariantsCount = filter.discountVariants()?.count ?? 0
        let privatePriceVariantsCount = filter.privatePriceVariants()?.count ?? 0
        let shouldAddDiscountItem = discountVariantsCount > 0 || privatePriceVariantsCount > 0
        if shouldAddDiscountItem {
            items.append(SortType.discount)
        }

        return items
    }

}
