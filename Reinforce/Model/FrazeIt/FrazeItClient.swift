//
//  FrazeItClient.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

class FrazeItClient : NSObject {

    func fetchQuotesForKeyword(_ keyword: String, page: Int, completionHandler: @escaping (_ error: NSError?, _ searchResult: QuoteSearchResult?, _ quotes: [Quote]?) -> Void) {
        let url = constructUrl(query: keyword, page: page)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            guard error == nil else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            guard data != nil else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            let xml = XML.parse(data!)
            let result = xml.result

            let searchResult = QuoteSearchResult(keyword: keyword, totalResults: result.total_results.int!, currentPage: page)

            guard searchResult.totalResults != 0 else {

                return
            }

            guard let quotesArray = result.quote.all else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            var quotes = [Quote]()
            for element in quotesArray {
                let quotation = Quote(text: element.text!, author: element.attributes[Constants.FrazeIt.authorKey], activities: element.attributes[Constants.FrazeIt.activitiesKey])
                quotes.append(quotation)
            }

            completionHandler(nil, searchResult, quotes)
        }
        task.resume()
    }


    func constructUrl(query: String, page: Int) -> URL {

        let escapedQuery = formatQueryString(queryString: query)
        let urlString = Constants.FrazeIt.baseUrl + escapedQuery + "/" + Constants.FrazeIt.lang + "/" + String(page) + "/" + Constants.FrazeIt.highlight + "/" + Constants.FrazeIt.apiKey
        print(escapedQuery)
        print(urlString)
        return URL(string:urlString)!
    }

    func formatQueryString(queryString: String) -> String {
        var query = queryString

        // Remove double whitespaces and replace remaining with '+'
        query = query.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        query = query.replacingOccurrences(of: " ", with: "+")

        // Apply a regex pattern
        let pattern = "[^A-Za-z+]+"
        query = query.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)

        return query
    }

}
