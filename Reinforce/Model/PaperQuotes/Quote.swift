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
    let author : String
    
    init(text: String, author: String) {
        self.text = text
        self.author = author
    }
}

struct QuoteSearchManager {
    var isSearching : Bool
    var currentDataTask : URLSessionDataTask
    var nextUrl : String?
    var totalResults : Int
    var resultsLeft : Int?

    init(isSearching: Bool, currentDataTask: URLSessionDataTask, nextUrl: String?, totalResults: Int) {
        self.isSearching = isSearching
        self.currentDataTask = currentDataTask
        self.nextUrl = nextUrl
        self.totalResults = totalResults
    }
}
