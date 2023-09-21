import Turbo
import SwiftKeychainWrapper
import UIKit
import WebKit
import Foundation
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate, WKNavigationDelegate {
    var window: UIWindow?
    var tokenString: String?
    private let navigationController = ViewController()
    let viewController = WebViewController()
    let baseUrl = "http://localhost:3000"
    var processPool: WKProcessPool = WKProcessPool()

    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        let scriptMessageHandler = ScriptMessageHandler()
        configuration.userContentController.add(scriptMessageHandler, name: "nativeApp")
        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        return session
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if let savedToken = fetchSavedToken() {
           // User is authenticated, show your existing content
           window?.rootViewController = navigationController
           navigationController.tabBar.delegate = self
           navigationController.pushViewController(viewController, animated: true)
        } else {
           // User is not authenticated, show the login screen
            let loginViewController = LoginViewController()
            window?.rootViewController = loginViewController
        }
        window?.makeKeyAndVisible()
        home()
    }

    
    func fetchSavedToken() -> String? {
        // Initialize KeychainSwift with your app's bundle identifier
        if let oauthToken = KeychainWrapper.standard.string(forKey: "OAuthTokenKey") {
            // Successfully retrieved the OAuth token
            return oauthToken
        } else {
            // OAuth token not found in the Keychain or an error occurred
            return nil
        }
    }
    
    func didLoginSuccessfully() {
        // Handle the successful login action here
        // This method will be called from LoginViewController when a successful login occurs
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        navigationController.tabBar.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func visit(url: URL) {
        viewController.visitableURL = url
        session.visit(viewController)
    }
    
    func home() {
        let url = URL(string: baseUrl)!
        visit(url: url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // This method is called when the web view has finished loading its content.
        // You can perform any post-loading tasks here
        home()
    }
    
}

extension SceneDelegate {
    func evaluateJavaScriptAndGetResult(completion: @escaping (String?) -> Void) {
        let javascript = "document.querySelector(\"meta[name='current-user-id']\").content" // Replace with your JavaScript code
        
        session.webView.evaluateJavaScript(javascript) { (result, error) in
            if let error = error {
                print("Error executing JavaScript: \(error)")
                completion(nil)
            } else if let resultValue = result as? String {
                print("JavaScript result: \(resultValue)")
                completion(resultValue)
            } else {
                print("JavaScript result is not a string.")
                completion(nil)
            }
        }
    }
}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: VisitProposal) {
        visit(url:proposal.url)
    }
    

    func session(_ session: Turbo.Session, didFailRequestForVisitable visitable: Turbo.Visitable, error: Error) {
        // TODO: Handle errors
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            // handle error
            // Create the URLRequest and add the OAuth header
            do {
                let url = URL(string: baseUrl + "/oauth/check_token")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let postParameters: [String: Any] = [
                    "token": fetchSavedToken()
                ]
                let jsonData = try JSONSerialization.data(withJSONObject: postParameters, options: .prettyPrinted)
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // Now, create a web view and load the request
                session.webView.navigationDelegate = self
                session.webView.load(request)
            } catch {
                print("There was an error")
            }
        }
    }


    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle dead web view.
    }
}


extension SceneDelegate: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Handle tab bar item selection here
        var userId = ""
        evaluateJavaScriptAndGetResult { resultValue in
            if let resultValue = resultValue {
                userId = resultValue
            } else {
                print("JavaScript execution failed or result is nil.")
            }
            
            let clickedTag = item.tag
            
            switch clickedTag {
            case 0:
               // Handle the item with tag 0 (itemHome)
                self.home()
            case 1:
               // Handle the item with tag 1 (itemUpload)
                let url = URL(string: "\(self.baseUrl)/audios/new")!
                self.visit(url: url)
            case 2:
                let url = URL(string: "\(self.baseUrl)/\(userId)/chats")!
                self.visit(url: url)
            case 3:
                let url = URL(string: "\(self.baseUrl)/\(userId)")!
                self.visit(url: url)
            default:
               // Handle any other cases
               break
            }
        }
    }
}
