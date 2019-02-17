//
//  Quote.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

struct Quote {
    let text : String
    let author : String?
    let activities : String?

    init(text: String, author: String?, activities: String?) {
        self.text = text
        self.author = author
        self.activities = activities
    }
}

struct QuoteSearchResult {
    let keyword : String
    let totalResults : Int
    var currentPage : Int
    var availablePages : Int { // Max number of pages allowed by API provider is 10.
        get {
            return (totalResults / 9) < 10 ? (totalResults/9) : 10
        }
    }
    var totalAccessibleResults: Int {
        get {
            if totalResults <= 90 { return totalResults } else { return 90 }
        }
    }
    
    var hasMore : Bool {
        get {
            return availablePages > currentPage ? true : false
        }
    }

    init(keyword : String, totalResults: Int, currentPage :Int) {
        self.keyword = keyword
        self.totalResults = totalResults
        self.currentPage = currentPage
    }
}

struct QuoteSearchManager {
    var isSearching : Bool
    var dataTask : URLSessionDataTask
    var searchResult : QuoteSearchResult? = nil

    init(isSearching: Bool, dataTask: URLSessionDataTask) {
        self.isSearching = isSearching
        self.dataTask = dataTask
    }
}
