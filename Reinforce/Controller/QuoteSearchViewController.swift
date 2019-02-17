//
//  QuotesSearchViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class QuoteSearchViewController : UIViewController {

    // MARK: - Properties and IBOutlets
    var searchResult : QuoteSearchResult?
    var quotes = [Quote]()
    let frazeItClient = FrazeItClient()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadMoreResultsButton: UIButton!


    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - IBActions

    @IBAction func loadMoreResultsButtonTapped(_ sender: UIButton) {
        print("Load more results button tapped")
        self.loadMoreResultsButton.isEnabled = false
        frazeItClient.fetchQuotesForKeyword((searchResult?.keyword)!, page: ((searchResult?.currentPage)! + 1), completionHandler: {
            error, result, quotes in
            self.processSearchResults(error: error, result: result, quotes: quotes, isFirst: false)
        })
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helper

    func processSearchResults(error: Error?, result: QuoteSearchResult?, quotes: [Quote]?, isFirst: Bool) {
        guard error == nil, result != nil, quotes != nil else {
            return
        }
        print("CurrentPage: \(String(describing: result?.currentPage)) Available Pages : \(String(describing: result?.availablePages)) AND hasMore: \(String(describing: result?.hasMore))")

        // If its a follow up request, increment the current page
        if isFirst {
            self.searchResult = result
        } else {
            self.searchResult?.currentPage += 1
        }

        self.quotes.append(contentsOf: quotes!)

        DispatchQueue.main.async {
            self.tableView.reloadData()
            let resultsLeft = (self.searchResult?.totalAccessibleResults)! - ((self.searchResult?.currentPage)! * 9)
            self.loadMoreResultsButton.setTitle("Load More Results (\(resultsLeft))", for: .normal)
            (self.searchResult?.hasMore)! ? self.loadMoreResultsButton.isEnabled = true : ()
        }
    }

    func resetSearchResults() {
        searchResult = nil
        quotes.removeAll()
        loadMoreResultsButton.setTitle("Load More Results", for: .normal)
        loadMoreResultsButton.isEnabled = false
        tableView.reloadData()
    }

}

// MARK: - UISearchBar

extension QuoteSearchViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Text Did End Editing")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let searchText = searchBar.text, searchText != "" else {
            return
        }

        // Reset
        resetSearchResults()

        frazeItClient.fetchQuotesForKeyword(searchText, page: 1, completionHandler: {
            error, result, quotes in
            self.processSearchResults(error: error, result: result, quotes: quotes, isFirst: true)
        })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel button was clicked")
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableView

extension QuoteSearchViewController : UITableViewDelegate, UITableViewDataSource {
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
