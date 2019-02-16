//
//  QuotesSearchViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class QuotesSearchViewController : UIViewController {

    var searchResult : QuoteSearchResult?
    var quotes = [Quote]()
    let frazeItClient = FrazeItClient()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadMoreResultsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

    }

    @IBAction func loadMoreResultsButtonTapped(_ sender: UIButton) {
        print("Load more results button tapped")
        self.loadMoreResultsButton.isEnabled = false
        frazeItClient.fetchQuotesForKeyword((searchResult?.keyword)!, page: ((searchResult?.currentPage)! + 1), completionHandler: {
            error, result, quotes in
            self.processSearchResults(error: error, result: result, quotes: quotes, isFirst: false)
        })
    }

}
extension QuotesSearchViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Text Did End Editing")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button was clicked")
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, searchText != "" else {
            return
        }
        frazeItClient.fetchQuotesForKeyword(searchText, page: 1, completionHandler: {
            error, result, quotes in
            self.processSearchResults(error: error, result: result, quotes: quotes, isFirst: true)
        })
    }

    func processSearchResults(error: Error?, result: QuoteSearchResult?, quotes: [Quote]?, isFirst: Bool) {
        guard error == nil, result != nil, quotes != nil else {
            return
        }
        print("Available Pages : \(result?.availablePages) AND hasMore: \(result?.hasMore)")
        print(result?.availablePages)
        
        if isFirst {
            self.searchResult = result
        } else {
            self.searchResult?.currentPage += 1
        }

        self.quotes.append(contentsOf: quotes!)

        DispatchQueue.main.async {
            self.tableView.reloadData()
            (self.searchResult?.hasMore)! ? self.loadMoreResultsButton.isEnabled = true : ()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel button was clicked")
        searchBar.resignFirstResponder()
    }
}

extension QuotesSearchViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return quotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quoteCell", for: indexPath)

        if !quotes.isEmpty {
            let quote = quotes[indexPath.row]
            cell.textLabel!.text = quote.text
            cell.detailTextLabel!.text = quote.author!
        }

        return cell
    }
}
