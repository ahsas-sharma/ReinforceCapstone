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
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var attachmentImageView: UIImageView!

        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code

            let shadowPath = UIBezierPath(rect: reminderView.bounds)
            reminderView.layer.cornerRadius = 5.0
            reminderView.clipsToBounds = true
            reminderView.layer.borderColor = UIColor.lightGray.cgColor
            reminderView.layer.borderWidth = 0.5
        }

//        override func setSelected(_ selected: Bool, animated: Bool) {
//            super.setSelected(!selected, animated: animated)
//        }
}
