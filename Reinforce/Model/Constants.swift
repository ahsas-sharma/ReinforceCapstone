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
        static let quotesSearchSegue = "QuoteSearchSegue"
        static let photoSearchSegue = "PhotoSearchSegue"
        static let paperQuotesViewController = "PaperQuotesViewController"
        static let unsplashViewController = "UnsplashViewController"

        struct Cells {
            static let homeTableViewCell = "HomeTableViewCell"
        }
    }

    // MARK: - TextView -
    struct TextView {
        static let defaultTitleText = "Tap to enter notification title"
        static let defaultBodyText = "Tap to start editing the body text or press the button below to search PaperQuote's library of over 2 million famous quotes."
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
    }
}
