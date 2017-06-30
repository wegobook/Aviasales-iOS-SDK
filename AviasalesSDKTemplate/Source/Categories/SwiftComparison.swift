import Foundation

extension Comparable {
    func compare(_ other: Self) -> ComparisonResult {
        if self > other {
            return .orderedAscending
        } else if self < other {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}
