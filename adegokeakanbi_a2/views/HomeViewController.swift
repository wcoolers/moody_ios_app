//
//  HomeViewController.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var logs: [MoodLog] = []
    let firestore = FirestoreManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        listenToLogs()

        // Profile button on the left
        let profileButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileTapped))
        navigationItem.leftBarButtonItem = profileButton

        // Logout button on the right
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItem = logoutButton
    }



    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeVC") as? WelcomeViewController {
                welcomeVC.modalPresentationStyle = .fullScreen
                self.present(welcomeVC, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    @objc func profileTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileViewController {
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }


    func listenToLogs() {
        firestore.listenToMoodLogs { logs in
            print("Fetched \(logs.count) logs") // 👈 Debug line
            self.logs = logs
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func addLogTapped(_ sender: Any) {
        let alert = UIAlertController(title: "New Mood Log", message: "How are you feeling?", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Mood description" }
        alert.addTextField { $0.placeholder = "Tags (comma separated)" }

        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            let mood = alert.textFields?[0].text ?? ""
            let tagsInput = alert.textFields?[1].text ?? ""
            let tags = tagsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            self.firestore.addMoodLog(moodText: mood, tags: tags) { success in
                if success {
                    print("Mood log added successfully")
                } else {
                    print("Failed to add mood log")
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = logs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "MoodCell")
        cell.textLabel?.text = log.moodText
        cell.detailTextLabel?.text = log.tags.joined(separator: " • ")
        return cell
    }

    // Navigate to Details VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLog = logs[indexPath.row]
        print("Selected log: \(selectedLog.moodText)")

        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as? DetailsViewController {
            detailsVC.moodLog = selectedLog
            navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            print("⚠️ Could not instantiate DetailsViewController")
        }
    }

}
