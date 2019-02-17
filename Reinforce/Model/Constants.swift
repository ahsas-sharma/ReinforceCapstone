//
//  Constants.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

struct Constants {

    // MARK: - FrazeIt -
    struct FrazeIt {
        // Networking
        static let baseUrl = "https://fraze.it/api/famous/"
        static let apiKey = "2cfe13dd-8d94-4aa0-9a5d-70a4daee6392"
        static let lang = "en"
        static let highlight = "no"
        static let maxPages = 10

        // XML
        static let authorKey = "author"
        static let activitiesKey = "activities"

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
