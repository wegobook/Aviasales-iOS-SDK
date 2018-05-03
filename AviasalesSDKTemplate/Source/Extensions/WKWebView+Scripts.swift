//
//  WKWebView+Scripts.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 28.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import WebKit

extension WKWebView {

    convenience init(scripts: [String]) {
        let userContentController = WKUserContentController()
        scripts.forEach { (script) in
            let userScript = WKUserScript.init(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            userContentController.addUserScript(userScript)
        }
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.init(frame: .zero, configuration: configuration)
    }
}
