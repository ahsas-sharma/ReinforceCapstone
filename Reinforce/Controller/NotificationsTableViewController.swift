//
//  NotificationsTableViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 20/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class NotificationsTableViewController : UITableViewController {

    // Controls
    @IBOutlet var dayButtonsCollection: [UIButton]!
    @IBOutlet weak var frequencyControl: UISegmentedControl!
    @IBOutlet weak var intervalStepper: UIStepper!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    // Labels
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var onceTimeLabel: UILabel!
    @IBOutlet weak var intervalHoursLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    // Time Settings Cells
    @IBOutlet weak var onceTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatIntervalTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatStartTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatEndTableViewCell: UITableViewCell!

    let sectionTitles : [Int: String] = [0:"Days",
                                         1:"Number of times per day",
                                         2:"Once a day",
                                         3:"Repeating",
                                         5:"Summary"]

    override func viewDidLoad() {
        super.viewDidLoad()
        styleDaysSelectionButtons(dayButtonsCollection)

        // Tableview adjustments for hiding and showing sections
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - IBActions

    // Common IBAction to handle selection of days
    @IBAction func toggleDaySelection(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateSummaryLabel()
    }



    @IBAction func segmentedControlIndexChanged(_ sender: UISegmentedControl) {
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        tableView.reloadSections(IndexSet(arrayLiteral: 2,3), with: .automatic)
    }

    // MARK: - TableView DataSource and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: if frequencyControl.selectedSegmentIndex == 0 { return 1 } else {return 0}
        case 3: if frequencyControl.selectedSegmentIndex == 1 { return 3 } else {return 0}
        case 4: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return 20} else {return 0.1}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return 20} else {return 0.1}
        } else { return 20 }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return sectionTitles[section]} else {return nil}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return sectionTitles[section]} else {return nil}
        } else { return sectionTitles[section] }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return 20} else {return 0.1}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return 30} else {return 0.1}
        } else { return 20 }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 && frequencyControl.selectedSegmentIndex == 1 { return "You will receieve notifications within these hours only."} else {return nil}
    }


    // MARK: - Helper
    func styleDaysSelectionButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.setBackgroundColor(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), forState: .selected)
            button.setTitleColor(.white, for: .selected)
        }
    }

    // TEST - Update summary label test
    func updateSummaryLabel() {
        var selectedDays = [String]()
        for button in dayButtonsCollection {
            if button.isSelected {
                selectedDays.append(button.titleLabel!.text!)
            }
        }
        let displayString = selectedDays.joined(separator: ", ")
        UIView.animate(withDuration: 0.1, animations: {
            self.summaryLabel.text = displayString
        })
    }
}

