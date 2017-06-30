import UIKit

extension Array {

    mutating func removeObject<T: Equatable>(_ object: T) {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? T {
                if object == to {
                    self.remove(at: idx)

                    return
                }
            }
        }
    }

    func objectsAtIndexes(_ indices: IndexSet) -> [Element] {
        var returnArray = [Element]()
        for (index, element) in self.enumerated() {
            if indices.contains(index) {
                returnArray.append(element)
            }
        }
        return returnArray
    }
}
