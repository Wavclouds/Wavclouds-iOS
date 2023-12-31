import WebKit

protocol ScriptMessageDelegate: AnyObject {
    func sendNotificationToken()
    func signout()
}

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var delegate: ScriptMessageDelegate?

    init(delegate: ScriptMessageDelegate) {
        self.delegate = delegate
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            let body = message.body as? [String: Any]
        else { return }
        let name = body["name"] as? String
        switch name {
        case "notification_access":
            delegate?.sendNotificationToken()
        case "signout":
            delegate?.signout()
        case "console_log":
            print("Console Log: \(body["message"]!)")
        default:
            return
        }
        
    }
}
