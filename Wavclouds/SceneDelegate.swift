import Turbo
import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigationController = ViewController()
    let viewController = WebViewController()

    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"

        let session = Session(webViewConfiguration: configuration)
        session.delegate = self
        return session
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        navigationController.tabBar.delegate = self
        navigationController.pushViewController(viewController, animated: true)
        window?.makeKeyAndVisible()
        home()
    }

    private func visit(url: URL) {
        viewController.visitableURL = url
        session.visit(viewController)
    }
    
    func home() {
        let url = URL(string: "http://localhost:3000")!
        visit(url: url)
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
        // TODO: Handle errors.
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
                let url = URL(string: "http://localhost:3000/audios/new")!
                self.visit(url: url)
            case 2:
                let url = URL(string: "http://localhost:3000/\(userId)/chats")!
                self.visit(url: url)
            case 3:
                let url = URL(string: "http://localhost:3000/\(userId)")!
                self.visit(url: url)
            default:
               // Handle any other cases
               break
            }
        }
    }
}
