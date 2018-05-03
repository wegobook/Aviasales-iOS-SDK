import Foundation

@objcMembers
class RoomsSorter: NSObject {

    class func sortRoomsByPrice(_ rooms: [HDKRoom], gatesSortOrder: [String]?) -> [HDKRoom] {
        return rooms.sorted {
            if $0.price != $1.price {
                return $0.price < $1.price
            }

            let firstGateIndex = gatesSortOrder?.index(of: $0.gate.gateId) ?? Int.max
            let secondGateIndex = gatesSortOrder?.index(of: $1.gate.gateId) ?? Int.max

            return firstGateIndex < secondGateIndex
        }
    }

    class func sortRoomsGroupsByPrice(_ groups: [[HDKRoom]]) -> [[HDKRoom]] {
        return groups.sorted(by: { (group1, group2) -> Bool in
            let price1 = group1.first?.price ?? .greatestFiniteMagnitude
            let price2 = group2.first?.price ?? .greatestFiniteMagnitude
            return price1 < price2
        })
    }
}
