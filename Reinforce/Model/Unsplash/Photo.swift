//
//  Photo.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

struct Photo {
    let thumbUrl : String
    var thumbImage : UIImage? = nil
    let fullUrl : String
    var fullImage : UIImage? = nil
    let user : UnsplashUser

    init(thumbUrl: String, fullUrl: String, user: UnsplashUser) {
        self.thumbUrl = thumbUrl
        self.fullUrl = fullUrl
        self.user = user
    }
}

struct UnsplashUser {
    let username : String
    let name: String
    let profileImageUrl : String
    var profileImage : UIImage?

    init(username: String, name: String, profileImageUrl: String) {
        self.username = username
        self.name = name
        self.profileImageUrl = profileImageUrl
    }
}
