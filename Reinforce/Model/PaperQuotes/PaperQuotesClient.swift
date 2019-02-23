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

    /// Makes a API call to PaperQuotesAPI with the tags entered by user and returns an array of quotes.
    func fetchQuotesForTags(_ tags: String, completionHandler: @escaping(_ error: NSError?,_ searchManager: QuoteSearchManager?,  _ quotes: [Quote]?)-> Void) {

        // Construct the url
        let urlString = Constants.PaperQuotes.baseUrl + formatQueryString(tags)
        let url = URL(string: urlString)!
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

            var nextString: String?
            if let nextUrlString = parsedResult?["next"] as? String {
                nextString = nextUrlString
            } else { nextString = nil}

            guard let count = parsedResult?["count"] as? Int else {
                print("Could not find the count key")
                return
            }

            guard let resultsArray = parsedResult?["results"] as? [[String: AnyObject]], resultsArray.count != 0 else {
                print("No results found")
                return
            }

            let searchManager = QuoteSearchManager(currentDataTask: self.currentTask, nextUrl: nextString, totalResults: count)
            let quotesArray = self.generateQuoteObjectsFromResults(resultsArray)
            completionHandler(nil, searchManager, quotesArray)

        }
        // Start the task
        currentTask.resume()
    }

    /// Returns an array of Quote objects using the results array from the parsed JSON response from PaperQuotes
    fileprivate func generateQuoteObjectsFromResults(_ results: [[String: AnyObject]]) -> [Quote] {
        var quoteArray = [Quote]()
        for item in results {
            if let text = item["quote"] as? String, let author = item["author"] as? String  {
                let quote = Quote(text: text, author: (author == "" ? "Unknown" : author))
                quoteArray.append(quote)
            }
        }
        return quoteArray
    }

    /// Makes a request to PaperQuotesAPI using the searchManager object's nextUrl property to continue an ongoing search. Returns an array of quotes.
    func fetchMoreQuotes(using searchManager: QuoteSearchManager, completionHandler: @escaping (_ error: NSError?,_ nextURL: String?,_ quotes: [Quote]?)-> Void) {

        print("Fetching more quotes from URL : \(String(describing: searchManager.nextUrl))")

        guard let nextUrlString = searchManager.nextUrl, let nextUrl = URL(string: nextUrlString) else {
            print("Next url not available")
            return
        }

        var request = URLRequest(url: nextUrl)
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

            var nextString: String?
            if let nextUrlString = parsedResult?["next"] as? String {
                nextString = nextUrlString
            } else { nextString = nil}

            guard let resultsArray = parsedResult?["results"] as? [[String: AnyObject]], resultsArray.count != 0 else {
                print("No results found")
                return
            }

            let quotesArray = self.generateQuoteObjectsFromResults(resultsArray)
            completionHandler(nil, nextString, quotesArray)
        }

        currentTask.resume()

    }
}

