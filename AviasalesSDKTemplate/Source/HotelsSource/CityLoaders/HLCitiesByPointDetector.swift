import UIKit
import CoreLocation
import HotellookSDK
import PromiseKit

class HLCitiesByPointDetector: NSObject {

    fileprivate var completionBlock: (([HDKCity]) -> Void)?
    fileprivate var errorBlock: ((NSError) -> Void)?

    func detectNearbyCitiesForSearchInfo(_ searchInfo: HLSearchInfo, onCompletion completionBlock: @escaping ([HDKCity]) -> Void, onError errorBlock: @escaping (NSError) -> Void) {
        self.completionBlock = completionBlock
        self.errorBlock = errorBlock

        guard let location = searchInfo.searchLocation() else {
            self.errorBlock?(NSError(code: HLErrorCode.invalidArgument))
            return
        }

        ServiceLocator.shared.api.nearbyCities(location: location).promise().then { cities in
            self.completionBlock?(cities)
        }.catch { error in
            self.errorBlock?(error as NSError)
        }
    }
}
