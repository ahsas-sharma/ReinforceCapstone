//
//  DesignViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class DesignViewController : UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var notificationVisualEffectsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        attachmentContainerView.isHidden = true
        print("DesignedViewController viewDidLoad Selected index : \(segmentedControl.selectedSegmentIndex)")
        notificationVisualEffectsView.layer.cornerRadius = 10
        notificationVisualEffectsView.clipsToBounds = true
    }

    @IBAction func selectionDidChange(_ sender: UISegmentedControl) {
        print("SelectionDidChange to index :\(sender.selectedSegmentIndex)")
        switchActiveView(toIndex: sender.selectedSegmentIndex)
    }

    private func switchActiveView(toIndex index: Int) {
        switch index {
        case 0:
            textContainerView.isHidden = false
            attachmentContainerView.isHidden = true
        case 1:
            textContainerView.isHidden = true
            attachmentContainerView.isHidden = false
        default: ()
        }

    }

}
