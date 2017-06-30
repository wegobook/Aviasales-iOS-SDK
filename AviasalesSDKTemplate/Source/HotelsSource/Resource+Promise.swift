import PromiseKit
import HotellookSDK

class CancelToken {
    var cancelHandler: (() -> Void)?

    func cancel() {
        cancelHandler?()
    }
}

extension HDKResource {

    func promise(cancelToken: CancelToken? = nil) -> Promise<T> {
        return Promise {[weak cancelToken] (fulfill, reject) in
            let executor = ServiceLocator.shared.requestExecutor
            let request = executor.load(resource: self, completion: { [weak cancelToken] (obj, err) in
                cancelToken?.cancelHandler = nil
                if let obj = obj {
                    fulfill(obj)
                } else {
                    reject(err!)
                }
            })
            cancelToken?.cancelHandler = { [weak request] in request?.cancel() }
        }
    }
}
