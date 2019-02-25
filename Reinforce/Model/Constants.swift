//
//  Constants.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

struct Constants {

    // MARK: - Common -
    static let textViewPlaceholderTextColor = UIColor(red: 0.821469, green: 0.821469, blue: 0.821469, alpha: 1)

    // MARK: - Identifiers -
    struct Identifiers {
        static let newDesignSegue = "NewDesignSegue"
        static let unsplashPhotoViewerSegue = "UnsplashPhotoViewerSegue"
        static let unsplashNavigationControllerSegue = "UnsplashNavigationControllerSegue"
        static let paperQuotesSegue = "PaperQuotesSegue"
        static let notificationScreenSegue = "NotificationScreenSegue"
        static let paperQuotesViewController = "PaperQuotesViewController"
        static let unsplashNavigationController = "UnsplashNavigationController"
        static let unsplashViewController = "UnsplashViewController"
        static let unsplashPhotoViewController = "UnsplashPhotoViewController"

        struct Cells {
            static let homeTableViewCell = "HomeTableViewCell"
            static let photoCollectionViewCell = "PhotoCollectionViewCell"
        }
    }

    // MARK: - TextView -
    struct TextView {
        static let defaultTitleText = "Tap to edit the title"
        static let defaultBodyText = "Tap to edit the body text.\nSearch PaperQuote's library of over 2 million famous quotes and add beautiful photos from Unsplash."
    }


    // MARK: - PaperQuotes -
    struct PaperQuotes {

        //TODO:- Added for testing (Construct properly later)
        static let baseUrl = "https://api.paperquotes.com/apiv1/quotes/?limit=30&lang=en&curated=1&order=likes&tags="

        // Base URL
        static let scheme = "https"
        static let apiHost = "api.paperquotes.com"
        static let apiPath = "/apiv1/quotes"

        // Parameter Keys
        static let limitKey = "limit"
        static let langKey = "lang"
        static let tagsKey = "tags"
        static let curatedKey = "curated"
        static let orderKey = "order"

        // Parameter Values
        static let limitVal = "30"
        static let langVal = "en"
        static let curatedVal = "1"
        static let orderVal = "likes"

        // Authorization
        static let authHeaderKey = "Authorization"
        static let authHeaderVal = "Token d30c02e44eb12fbd8d737bb32a360637e7f0569f"
    }

    // MARK: - Unsplash -
    struct Unsplash {
        static let baseUrl = "https://api.unsplash.com/search/photos?"

        // Parameter Keys
        static let clientIdKey = "client_id"
        static let pageKey = "page"
        static let perPageKey = "per_page"
        static let queryKey = "query"

        // Parameter Values
        static let clientId = "8347e7035be3d91402b253f0939b4421b17ba137785390e7152f3ad67645a8a7"
        static let perPage = "30"

        // Response Keys
        static let nextUrlKey = ""
        static let resultsKey = "results"
        static let urlsKey = "urls"
        static let thumbUrlKey = "thumb"
        static let fullUrlKey = "regular" // this is actually the regularUrlKey. Refactor key and model attributes later.
        static let userKey = "user"
        static let usernameKey = "username"
        static let profileImageKey = "profile_image"
        static let largeProfileImageKey = "large"
        static let nameKey = "name"

    }

    // MARK: - Errors -
    struct Errors {
        static let noPhotosFound = NSError(domain: "No photos found", code: 404, userInfo: [NSLocalizedDescriptionKey:"Could not find any photos for the given keywords."])
        static let noQuotesFound = NSError(domain: "No quotes found", code: 404, userInfo: [NSLocalizedDescriptionKey:"Could not find any quotes for the given tags."])
        static let noNetwork = NSError(domain: "No internet access", code: 1, userInfo: [NSLocalizedDescriptionKey:"Please make sure you're connected to a network and try again."])
        static let database = NSError(domain: "Database error", code: 2, userInfo: [NSLocalizedDescriptionKey:"Well this is just embarrassing. Please contact the developer."])
        static let unsplash = NSError(domain: "Invalid response from Unsplash API", code: 3, userInfo: [NSLocalizedDescriptionKey:"Please try again. If the problem persists, contact the developer."])
        static let paperQuotes = NSError(domain: "Invalid response from PaperQuotes API", code: 3, userInfo: [NSLocalizedDescriptionKey:"Please try again. If the problem persists, contact the developer."])
        static let networkErrorCodes = [1001, 1004, 1005, 1006, 1009, 1018, 1019, 999, 53, -1009]
    }
}
