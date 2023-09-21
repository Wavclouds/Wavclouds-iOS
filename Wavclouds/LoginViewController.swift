import UIKit
import Foundation
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    // Add your UI elements for user login (e.g., text fields, buttons, etc.)
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Customize your UI elements here
        view.backgroundColor = .blue
        
        // Add and configure UI elements (e.g., usernameTextField, passwordTextField, loginButton)
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        usernameTextField.textColor = .white
        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        passwordTextField.textColor = .white
        passwordTextField.isSecureTextEntry = true

        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .darkGray
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wavclouds") // Replace "your_image_name" with the actual image name from your assets
        imageView.contentMode = .scaleAspectFit
        
        imageView.heightAnchor.constraint(equalToConstant: 225).isActive = true // Set the desired height
        imageView.widthAnchor.constraint(equalToConstant: 225).isActive = true // Set the desired width

        // Add UI elements to the view
        let stackView = UIStackView(arrangedSubviews: [imageView, UIView(), usernameTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        let blankView = stackView.arrangedSubviews[1] // The second view (index 1) is the blank view
        blankView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true // Adjust the height as needed

        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func loginButtonTapped() {
        // Implement your authentication logic here
        print("HEY: YOU CLICKED THE BUTN")
        if let username = usernameTextField.text, let password = passwordTextField.text {
            attemptLogin(username: username, password: password) { result in
                switch result {
                case .success(let oauthResponse):
                    // Handle a successful login here
                    print("Login successful. Access Token: \(oauthResponse.oauth_token)")
                    // You can perform any actions you need after a successful login.
                    let saved = KeychainWrapper.standard.set(oauthResponse.oauth_token, forKey: "OAuthTokenKey")

                    // If you need to notify a delegate or update UI, do so here.
                    if saved {
                        self.delegate?.didLoginSuccessfully()
                    }

                case .failure(let error):
                    // Handle a login failure here
                    print("Login failed with error: \(error.localizedDescription)")
                    // You can display an error message to the user or take other appropriate actions.
                }
            }
        }
    }
    
    func attemptLogin(username: String, password: String, completion: @escaping (Result<OauthResponse, Error>) -> Void) {
        // Define the URL of your Rails server's endpoint
        guard let url = URL(string: "http://localhost:3000/oauth/token") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession
        let session = URLSession.shared

        // Create a dictionary for the request body parameters
        let params: [String: Any] = [
            "login": username,
            "password": password
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
                } else if let data = data {
                    // Handle the response data here
                    // You can parse the JSON response using Codable
                    do {
                        let decodedData = try JSONDecoder().decode(OauthResponse.self, from: data)
                        // Handle the decoded data
                        completion(.success(decodedData))
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(.failure(error))
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


    
    // Create a delegate to notify the SceneDelegate when the user logs in successfully
    weak var delegate: LoginViewControllerDelegate?
}

// Delegate protocol to notify the SceneDelegate when the user logs in successfully
protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
}

struct OauthResponse: Codable {
    // Define properties that match the JSON structure
    let oauth_token: String
    // Add more properties as needed
}
