@objcMembers
class ResultsTTLManager: NSObject {
    private let store: SearchConfigStore

    private let kFallbackResultsTTL = 60 * 60

    init(store: SearchConfigStore) {
        self.store = store
    }

    func resultsTTL(forGate gateId: String) -> Int {
        let result = store.resultsTTLByGate()[gateId] ?? store.defaultResultsTTL()
        return result > 0 ? result : kFallbackResultsTTL
    }

    func minResultsTTL() -> Int {
        let minResultsByGate = store.resultsTTLByGate().values.min() ?? Int.max
        let result = min(minResultsByGate, store.defaultResultsTTL())
        return result > 0 ? result : kFallbackResultsTTL
    }
}
