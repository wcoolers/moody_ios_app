//
//  DetailsViewController.swift
//  adegokeakanbi_a2
//
//  Created by Adegoke on 2025-04-16.
//

import UIKit

class DetailsViewController: UIViewController {

    var moodLog: MoodLog? // data passed from HomeViewController

    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mood Details"
        displayMoodDetails()
    }

    func displayMoodDetails() {
        guard let log = moodLog else { return }

        moodLabel.text = "Mood: \(log.moodText)"
        tagsLabel.text = "Tags: \(log.tags.joined(separator: ", "))"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = "Date: \(formatter.string(from: log.timestamp))"
    }
}
