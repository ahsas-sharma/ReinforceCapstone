//
//  UnsplashPhotoViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 23/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class UnsplashPhotoViewController : UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fullImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDetailsView: UIView!

    var photo: Photo!
    var designViewController : DesignViewController!
    let unsplashClient = UnsplashClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnTap = true
        userDetailsView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        styleUserProfileImageView()
        loadFullImage()
        loadUserDetails()
        if photo.fullImage == nil { doneButton.isEnabled = false }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true

    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let fullImageData = self.photo.fullImage else {
            print("Could not get full image data")
            return
        }
        designViewController.attachmentImageView.image = UIImage(data: fullImageData)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    /// Checks if the high-resolution version of the photo is already available and downloads it if required.
    fileprivate func loadFullImage() {
        if let fullImage = photo.fullImage {
            activityIndicator.stopAnimating()
            self.fullImageView.image = UIImage(data: fullImage)
        } else {
            activityIndicator.startAnimating()
            // if thumb image is available, set that for now
            if let thumbImage = photo.thumbImage {
                fullImageView.image = UIImage(data: thumbImage)
            }
            unsplashClient.downloadFullResolutionImage(forPhoto: photo, completionHandler: {
                error, imageData in
                self.stopActivityIndicator()
                guard error == nil, imageData != nil else {
                    print("Error while trying to download the full image")
                    return
                }
                DispatchQueue.main.async {
                    self.fullImageView.image = UIImage(data: imageData!)
                    self.doneButton.isEnabled = true
                }
            })
        }
    }

    /// Adds corner radius to create circle effect for profile imageView.
    fileprivate func styleUserProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.clipsToBounds = true
    }

    /// Displays username, fullname and profile image of the Unsplash user who created this photo
    fileprivate func loadUserDetails() {
        self.fullNameLabel.text = (photo.name != nil ? photo.name : "Not available")
        self.usernameLabel.text = (photo.username != nil ? photo.username : "Not available")

        if let profileImage = photo.profileImage {
            self.profileImageView.image = UIImage(data: profileImage)
        } else {
            profileImageView.image = UIImage(named:"placeholder")
            unsplashClient.downloadUserProfileImage(forPhoto: photo, completionHandler: {
                error, imageData in
                guard error == nil, imageData != nil else {
                    print("Error while trying to download the full image")
                    return
                }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: imageData!)
                }
            })
        }
    }

    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

}
