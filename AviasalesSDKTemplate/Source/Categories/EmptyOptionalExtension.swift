protocol EmptyCollection {
    var isEmpty: Bool { get }
}

extension String: EmptyCollection { }
extension Array: EmptyCollection { }
extension Dictionary: EmptyCollection { }
extension Set: EmptyCollection { }

extension Optional where Wrapped: EmptyCollection {
    func isNilOrEmpty() -> Bool {
        return self?.isEmpty ?? true
    }

    func unwrapIfNotEmpty() -> Wrapped? {
        return isNilOrEmpty() ? nil : self!
    }
}
