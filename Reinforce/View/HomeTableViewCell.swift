//
//  HomeTableViewCell.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 22/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class HomeTableViewCell : UITableViewCell {

    @IBOutlet weak var reminderView: UIView!

    var reminder : Reminder! {
        didSet{
            self.titleLabel.text = reminder.title
            self.bodyLabel.text = reminder.body
            self.attachmentImageView.image = UIImage(data: reminder.image!)
            self.weekdaysLabel.text = reminder.weekdays
            // TODO: - Fix UI mess up for more than 5 days
            self.timeLabel.text = reminder.timeString
        }
    }
    
    @IBOutlet weak var notificationIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var weekdaysLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reminderView.layer.cornerRadius = 5.0
        reminderView.clipsToBounds = true
        reminderView.layer.borderColor = UIColor.lightGray.cgColor
        reminderView.layer.borderWidth = 0.5
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if !sender.isOn {
//            activeNotificationsForReminder() // TEST
            UIView.animate(withDuration: 0.5, animations: {
                self.weekdaysLabel.isEnabled = false
                self.timeLabel.isEnabled = false
                self.notificationIconImageView.image = UIImage(named:"notification_silent")
            })

        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.weekdaysLabel.isEnabled = true
                self.timeLabel.isEnabled = true
                self.notificationIconImageView.image = UIImage(named:"home_notification")
            })

        }
    }

    func activeNotificationsForReminder() {
        let notificationRequests = reminder.requests as! [Request]
        var identifiers = [UUID]()
        for request in notificationRequests {
            print(request.identifier)
            identifiers.append(request.identifier!)
        }



    }


}
