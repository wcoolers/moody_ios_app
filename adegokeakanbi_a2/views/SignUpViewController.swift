//
//  SignUpViewController.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//
import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmPasswordField.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert("Please fill in all fields.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert("Passwords do not match.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("Error: \(error.localizedDescription)")
            } else {
                self.showAlert("Account created!", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}

