import Foundation

class ServiceLocator: NSObject {

    static let shared = ServiceLocator()

    let api: HDKResourceFactory
    let sdkFacade: HDKFacade
    let requestExecutor: HDKRequestExecutor
    let searchConfigStore: SearchConfigStore
    let resultsTTLManager: ResultsTTLManager

    override init() {
        searchConfigStore = SearchConfigStore()
        resultsTTLManager = ResultsTTLManager(store: searchConfigStore)
        let hostName = iPhone() ? "iphone.hotellook.sdk" : "ipad.hotellook.sdk"
        api = HDKResourceFactory(appHostName: hostName, lang: HLLocaleInspector.shared().localeString())
        requestExecutor = HDKRequestExecutor()
        sdkFacade = HDKFacade(api: api, requestExecutor: requestExecutor)
    }
}
