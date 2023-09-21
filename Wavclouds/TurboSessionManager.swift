//
//  TurboSessionManager.swift
//  Wavclouds
//
//  Created by Enoch Tamulonis on 9/20/23.
//

import Turbo
import WebKit

class TurboSessionManager {
    static let shared = TurboSessionManager()
    
    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        let scriptMessageHandler = ScriptMessageHandler()
        configuration.userContentController.add(scriptMessageHandler, name: "nativeApp")
        let session = Session(webViewConfiguration: configuration)
        session.delegate = SceneDelegate.shared // Assuming SceneDelegate conforms to SessionDelegate
        return session
    }()
    
    func getSession() -> Session {
        return session
    }
}
