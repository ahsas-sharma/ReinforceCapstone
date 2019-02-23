//
//  UnsplashPhotoViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 23/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class UnsplashPhotoViewController : UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fullImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDetailsView: UIView!

    var photo: Photo!
    let unsplashClient = UnsplashClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        userDetailsView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        styleUserProfileImageView()
        loadFullImage()
        loadUserDetails()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
    }

    func loadFullImage() {
        if let fullImage = photo.fullImage {
            activityIndicator.stopAnimating()
            self.fullImageView.image = UIImage(data: fullImage)
        } else {
            activityIndicator.startAnimating()
            fullImageView.image = UIImage(data: photo.thumbImage!)
            unsplashClient.downloadFullResolutionImage(forPhoto: photo, completionHandler: {
                error, imageData in
                self.stopActivityIndicator()
                guard error == nil, imageData != nil else {
                    print("Error while trying to download the full image")
                    return
                }
                DispatchQueue.main.async {
                    self.fullImageView.image = UIImage(data: imageData!)
                }
            })
        }
    }

    func styleUserProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.clipsToBounds = true
    }

    func loadUserDetails() {
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
