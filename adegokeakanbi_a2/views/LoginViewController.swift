//
//  LoginViewController.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//
import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore


class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert("Please enter email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("Login failed: \(error.localizedDescription)")
            } else {
                self.navigateToHome()
            }
        }
    }
    
    
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController {
            let navController = UINavigationController(rootViewController: homeVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }

    }
    
    @IBAction func googleSignInTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }

        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else {
                print("No user found after sign-in")
                return
            }

            let idToken = user.idToken!.tokenString
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in failed: \(error.localizedDescription)")
                } else {
                    print("Signed in with Google: \(authResult?.user.email ?? "No Email")")
                    
                    // ✅ Redirect to HomeViewController
                    self.navigateToHome()
                }
            }

        }
    }


}
