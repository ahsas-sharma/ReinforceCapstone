//
//  PaperQuotesClient.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 20/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

class PaperQuotesClient : NSObject {

    var currentTask : URLSessionDataTask!

    func fetchQuotesForKeyword(_ keyword: String, next: String?, completionHandler: @escaping(_ error: NSError?,_ searchManager: QuoteSearchManager?,  _ quotes: [Quote]?)-> Void) {

        // Construct the url
        var urlString : String!
        if let next = next {
            urlString = next
        } else {
            urlString = Constants.PaperQuotes.baseUrl + formatQueryString(keyword)
        }

        let url = URL(string: urlString)!
        print("UrlString : \(String(describing: urlString))")
        var request = URLRequest(url: url)
        request.setValue(Constants.PaperQuotes.authHeaderVal, forHTTPHeaderField: Constants.PaperQuotes.authHeaderKey)

        currentTask = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard error == nil else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            guard data != nil else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            var parsedResult : AnyObject?
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            } catch {
                print("Error while parsing JSON")
            }

            guard let nextUrlString = parsedResult?["next"] as? String else {
                print("Could not find next url string")
                return
            }

            guard let count = parsedResult?["count"] as? Int else {
                print("Could not find the count key")
                return
            }

            guard let quotesArray = parsedResult?["results"] as? [[String: AnyObject]] else{
                print("Could not find results key in parsed results")
                return
            }

            let searchManager = QuoteSearchManager(isSearching: true, currentDataTask: self.currentTask, nextUrl: nextUrlString, totalResults: count)

            var returnArray = [Quote]()

            for item in quotesArray {

                guard let text = item["quote"] as? String else {
                    return
                }

                guard let author = item["author"] as? String else {
                    return
                }

                let quote = Quote(text: text, author: (author == "" ? "Unknown" : author))
                returnArray.append(quote)
            }

            completionHandler(nil, searchManager, returnArray)

        }
        // Start the task
        currentTask.resume()
    }

}
