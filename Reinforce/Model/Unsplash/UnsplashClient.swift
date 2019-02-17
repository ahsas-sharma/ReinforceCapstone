//
//  UnsplashClient.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

class UnsplashClient : NSObject {

    func searchPhotosByKeywords(_ keywords: String) {
        
    }

    func constructUrl(query: String, page: Int) -> URL {
        let escapedQuery = formatQueryString(queryString: query)
        let urlString = Constants.Unsplash.baseUrl + Constants.Unsplash.clientIdKey + "=" + Constants.Unsplash.clientId + "&" + Constants.Unsplash.queryKey + "=" + query + "&" + Constants.Unsplash.pageKey + "=" + String(page) + "&" + Constants.Unsplash.perPageKey + "=" + Constants.Unsplash.perPage
        let url = URL(string: urlString)!
        print(escapedQuery)
        return url
    }
}
