import Foundation

@objcMembers
class SearchConfigStore: NSObject {

    private let kResultsTTLKey = "kResultsTTLKey"
    private let kResultsTTLByGateKey = "kResultsTTLByGateKey"

    private var cachedDefaultResultsTTL: Int
    private var cachedResultsTTLByGate: [String: Int]

    override init() {
        cachedResultsTTLByGate = HDKDefaultsSaver.loadObjectWithKey(kResultsTTLByGateKey) as? [String: Int] ?? [:]
        cachedDefaultResultsTTL = HDKDefaultsSaver.loadIntegerWithKey(kResultsTTLKey)
    }

    func saveResultsTTL(_ ttlByGate: [String: Int], ttlDefault: Int) {
        cachedResultsTTLByGate = ttlByGate
        HDKDefaultsSaver.saveObject(ttlByGate, forKey: kResultsTTLByGateKey)

        cachedDefaultResultsTTL = ttlDefault
        HDKDefaultsSaver.saveInteger(ttlDefault, forKey: kResultsTTLKey)
    }

    func resultsTTLByGate() -> [String: Int] {
        return cachedResultsTTLByGate
    }

    func defaultResultsTTL() -> Int {
        return cachedDefaultResultsTTL
    }
}
