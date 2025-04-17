//
//  ProfileViewController.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//
import UIKit
import FirebaseStorage
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        fetchProfileImage()
    }

    @IBAction func uploadTapped(_ sender: UIButton) {
        print("Upload tapped ✅")
        presentImagePicker()
        
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        presentImagePicker() // same as upload
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteProfileImage()
    }

    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            self.profileImageView.image = image
            uploadImageToFirebase(image)
        }
    }

    func uploadImageToFirebase(_ image: UIImage) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
            } else {
                print("Profile image uploaded.")
            }
        }
    }

    func fetchProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        
        storageRef.downloadURL { url, error in
            if let url = url {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
    }

    func deleteProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")

        storageRef.delete { error in
            if let error = error {
                print("Delete failed: \(error.localizedDescription)")
            } else {
                print("Profile image deleted.")
                DispatchQueue.main.async {
                    self.profileImageView.image = nil
                }
            }
        }
    }
}

