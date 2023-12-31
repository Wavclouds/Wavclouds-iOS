//
//  RegisterViewController.swift
//  Wavclouds
//
//  Created by Enoch Tamulonis on 10/9/23.
//

import Foundation
import WebKit
import SwiftKeychainWrapper

class RegisterViewController: UIViewController {
    // Add your UI elements for user login (e.g., text fields, buttons, etc.)
    private let usernameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let errorMessage = UITextView()
    let baseUrl = Constants.baseUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        // Setup UI
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
        usernameTextField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        // Add a border to the text fields
        usernameTextField.layer.borderWidth = 1.0
        usernameTextField.layer.borderColor = UIColor.lightGray.cgColor
        usernameTextField.layer.cornerRadius = 8.0  // Optional: Add rounded corners for a nicer look

        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.cornerRadius = 8.0  // Optional: Add rounded corners for a nicer look
        
        emailTextField.placeholder = "Email"
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        emailTextField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        // Add a border to the text fields
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.cornerRadius = 8.0  // Optional: Add rounded corners for a nicer look
        // Add padding to the inner text
        let emailPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: emailTextField.frame.height))
        emailTextField.leftView = emailPaddingView
        emailTextField.leftViewMode = .always
        
        
        // Add padding to the inner text
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: usernameTextField.frame.height))
        usernameTextField.leftView = paddingView
        usernameTextField.leftViewMode = .always

        let passwordPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: passwordTextField.frame.height))
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = .always
        
        registerButton.setTitle("Create account", for: .normal)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        // Customize the login button
        registerButton.layer.cornerRadius = 8.0
        registerButton.layer.masksToBounds = true
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0) // Customize button color

        // Add shadow to the login button (optional)
        registerButton.layer.shadowColor = UIColor.gray.cgColor
        registerButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        registerButton.layer.shadowOpacity = 0.5
        registerButton.layer.shadowRadius = 2.0

        errorMessage.isEditable = false
        errorMessage.textColor = .red
        errorMessage.backgroundColor = .clear
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        errorMessage.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        // Create a "Create an Account" button
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Already have an account? Sign in", for: .normal)
        loginButton.setTitleColor(.lightGray, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.image = UIImage(named: "wavclouds") // Replace "your_image_name" with the actual image name from your assets
        imageView.contentMode = .scaleAspectFit
        
        imageView.heightAnchor.constraint(equalToConstant: 225).isActive = true // Set the desired height
        imageView.widthAnchor.constraint(equalToConstant: 225).isActive = true // Set the desired width
        
        
        // Add UI elements to the view
        let stackView = UIStackView(arrangedSubviews: [imageView, UIView(), errorMessage, usernameTextField, emailTextField, passwordTextField, registerButton, loginButton])
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
        // Open the URL in the browser when the "Create an Account" button is tapped
        self.delegate!.showLoginScreen()
    }
    
    @objc private func registerButtonTapped() {
        // Implement your authentication logic here
        errorMessage.text = ""
        print("HEY: YOU CLICKED THE BUTN")
        if let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text {
            attemptRegister(username: username, email: email, password: password) { result in
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
                    DispatchQueue.main.async {
                        self.errorMessage.text = "There was an issue creating your account"
                    }
                }
            }
        }
    }
    
    func attemptRegister(username: String, email: String, password: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        // Define the URL of your Rails server's endpoint
        guard let url = URL(string: baseUrl + "/api/v1/users") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Create a URLSession
        let session = URLSession.shared

        // Create a dictionary for the request body parameters
        let params: [String: Any] = [
            "username": username,
            "email": email,
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
                        let decodedData = try JSONDecoder().decode(RegisterResponse.self, from: data)
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
    weak var delegate: RegisterViewControllerDelegate?
}


// Delegate protocol to notify the SceneDelegate when the user logs in successfully
protocol RegisterViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
    func showLoginScreen()
}

struct RegisterResponse: Codable {
    // Define properties that match the JSON structure
    let oauth_token: String
    // Add more properties as needed
}
