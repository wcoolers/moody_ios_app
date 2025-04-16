//
//  FirestoreManager.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct MoodLog {
    let id: String
    let moodText: String
    let tags: [String]
    let timestamp: Date
}

class FirestoreManager {
    private let db = Firestore.firestore()
    private let collection = "moodLogs"
    
    func listenToMoodLogs(completion: @escaping ([MoodLog]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        print("Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")


        db.collection(collection)
            .whereField("userID", isEqualTo: userID)  // ✅ Consistent with addMoodLog
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error listening to logs: \(error)")
                    completion([])
                    return
                }

                var logs: [MoodLog] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let moodText = data["moodText"] as? String,
                       let tags = data["tags"] as? [String],
                       let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() {

                        let log = MoodLog(id: document.documentID, moodText: moodText, tags: tags, timestamp: timestamp)
                        logs.append(log)
                    }
                }

                print("Fetched \(logs.count) logs")
                completion(logs)
            }
    }
    
    func addMoodLog(moodText: String, tags: [String], completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        
        let data: [String: Any] = [
            "moodText": moodText,
            "tags": tags,
            "timestamp": Timestamp(date: Date()),
            "userID": user.uid  // ✅ Matches the query field above
        ]
        
        db.collection(collection).addDocument(data: data) { error in
            if let error = error {
                print("Error adding mood log: \(error.localizedDescription)")
            } else {
                print("Mood log added successfully.")
            }
            completion(error == nil)
        }
    }
    
    func fetchMoodLogs(completion: @escaping ([MoodLog]) -> Void) {
        guard let user = Auth.auth().currentUser else { return }

        db.collection(collection)
            .whereField("userID", isEqualTo: user.uid)  // ✅ Consistent again
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                var logs: [MoodLog] = []
                if let docs = snapshot?.documents {
                    for doc in docs {
                        let data = doc.data()
                        let mood = data["moodText"] as? String ?? ""
                        let tags = data["tags"] as? [String] ?? []
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        logs.append(MoodLog(id: doc.documentID, moodText: mood, tags: tags, timestamp: timestamp))
                    }
                }
                print("Fetched \(logs.count) logs from fetchMoodLogs")
                completion(logs)
            }
    }
}
