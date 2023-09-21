//
//  ScriptMessageHandler.swift
//  Wavclouds
//
//  Created by Enoch Tamulonis on 9/17/23.
//

import Foundation
import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print("JavaScript message received", message.body)
        // TODO HANDLE THIS
        let session = SceneDelegate().getSession()
        let javascript = "document.body.innerHTML"
        session.webView.evaluateJavaScript(javascript) { r, e in
            print("Result: \(r)")
        }
    }
}
