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
    let baseUrl = Constants.baseUrl
    var processPool: WKProcessPool = WKProcessPool()

    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        let scriptMessageHandler = ScriptMessageHandler(delegate: self)
        configuration.userContentController.add(scriptMessageHandler, name: "nativeApp")
        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        return session
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if fetchSavedToken() != nil {
           // User is authenticated, show your existing content
            window?.rootViewController = navigationController
            navigationController.tabBar.delegate = self
            navigationController.pushViewController(viewController, animated: true)
        } else {
           showLoginScreen()
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
    
    func showLoginScreen() {
        // User is not authenticated, show the login screen
        DispatchQueue.main.async {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            self.window?.rootViewController = loginViewController
        }
    }
    
    func showRegisterScreen() {
        DispatchQueue.main.async {
            let registerViewController = RegisterViewController()
            registerViewController.delegate = self
            self.window?.rootViewController = registerViewController
        }
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
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            // Create the URLRequest and add the OAuth header
            do {
                if let savedToken = fetchSavedToken() {
                    checkStatusOfToken(token: savedToken) { result in
                        switch result {
                        case .success(let responseString):
                            print("Request was successful! Response data: \(responseString)")
                        case .failure(let error):
                            print("Request failed with error: \(error)")
                            self.signout()
                        }
                    }
                    
                    let url = URL(string: baseUrl + "/oauth/check_token")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    let postParameters: [String: Any] = [
                        "token": savedToken
                    ]
                    let jsonData = try JSONSerialization.data(withJSONObject: postParameters, options: .prettyPrinted)
                    request.httpBody = jsonData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    // Now, create a web view and load the request
                    session.webView.navigationDelegate = self
                    session.webView.load(request)
                } else {
                    print("TOKEN WAS NOT STORED ACTUALLY")
                }
            } catch {
                print("There was an error")
            }
        }
    }


    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle dead web view.
    }
}

enum RequestError: Error {
    case invalidResponse
    case unsuccessfulStatusCode(Int)
    case dataSerializationError
}

extension SceneDelegate {
    func checkStatusOfToken(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseUrl + "/oauth/check_token") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession
        let session = URLSession.shared

        // Create a dictionary for the request body parameters
        let params: [String: Any] = [
            "token": token,
        ]

        // Create a request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Convert the parameters to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])

            // Set the request body
            request.httpBody = jsonData

            // Set the request headers
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Create a data task to send the POST request
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(.failure(error))
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        // Handle 401 Unauthorized
                        print("Unauthorized: \(httpResponse)")
                        completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
                    } else if httpResponse.statusCode == 200 {
                        // Handle success
                        completion(.success("Success"))
                    } else {
                        // Handle other status codes
                        print("Unexpected status code: \(httpResponse.statusCode)")
                        completion(.failure(NSError(domain: "Unexpected status code", code: httpResponse.statusCode, userInfo: nil)))
                    }
                }
            }

            // Start the data task
            task.resume()
        } catch {
            print("Error converting parameters to JSON: \(error)")
            completion(.failure(error))
        }
    }
}

extension SceneDelegate: LoginViewControllerDelegate, RegisterViewControllerDelegate {
    func didLoginSuccessfully() {
        // Handle the successful login action here
        // This method will be called from LoginViewController when a successful login occurs
        DispatchQueue.main.async {
            self.session.reload()
            self.window?.rootViewController = self.navigationController
            self.navigationController.tabBar.delegate = self
            if !self.navigationController.viewControllers.contains(self.viewController) {
               // Push the view controller onto the navigation stack
               self.navigationController.pushViewController(self.viewController, animated: true)
               self.home()
            }
        }
    }
}

extension SceneDelegate: ScriptMessageDelegate {
    func sendNotificationToken() {
        // Implement the delegate method
        // This method will be called when the script message handler receives a message
        if let storedToken = UserDefaults.standard.string(forKey: "DeviceToken") {
            // Use the storedToken as needed
            print("Stored Device Token: \(storedToken)")
            let javascript = "window.bridge.registerToken('\(storedToken)');"
            session.webView.evaluateJavaScript(javascript) { result, error in
                
            }
        } else {
            // Device token not found in UserDefaults
            print("Device Token not found.")
        }
    }
    
    func signout() {
       let removed = KeychainWrapper.standard.removeObject(forKey: "OAuthTokenKey")
       if removed {
           print("OAuth token removed successfully")
           showLoginScreen()
       } else {
           print("Error removing OAuth token from keychain")
       }
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
