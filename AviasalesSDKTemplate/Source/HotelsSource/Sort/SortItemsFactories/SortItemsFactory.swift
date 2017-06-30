class SortItemsFactory: NSObject {
    func sortTypesForFilter(_ filter: Filter) -> [SortType] {
        return [SortType.popularity, SortType.price, SortType.distance]
    }
}
