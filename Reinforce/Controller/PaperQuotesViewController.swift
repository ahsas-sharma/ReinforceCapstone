//
//  PaperQuotesViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 16/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit

class PaperQuotesViewController : UIViewController {

    // MARK: - Properties and IBOutlets
    var quotes = [Quote]()
    var designViewController : DesignViewController!
    var selectedQuote : Quote!

    let paperQuotesClient = PaperQuotesClient()
    var quoteSearchManager : QuoteSearchManager!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadMoreResultsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var doneButton: UIBarButtonItem!


    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        noResultsView.isHidden = true
        doneButton.isEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        self.activityIndicator.stopAnimating()
    }

    // MARK: - IBActions

    @IBAction func loadMoreResultsButtonTapped(_ sender: UIButton) {
        print("Load more results button tapped")
        self.loadMoreResultsButton.isEnabled = false
        self.activityIndicator.startAnimating()
        paperQuotesClient.fetchMoreQuotes(using: quoteSearchManager, completionHandler: {
            error, nextUrlString, newQuotes in
            guard error == nil else {
                print("There was an error : \(String(describing: error))")
                return
            }
            self.quoteSearchManager.nextUrl = nextUrlString
            let lastRow = self.quotes.count
            self.quotes += newQuotes!
            print("NewQuotes Count: \(newQuotes!.count)")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .middle, animated: true)
                if nextUrlString != nil {
                    self.loadMoreResultsButton.isEnabled = true
                }
            }
        })
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        updatePreviewUIWithQuote(selectedQuote)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helper

    func updatePreviewUIWithQuote(_ quote: Quote) {
        designViewController.bodyTextView.text = selectedQuote.text
        designViewController.bodyTextView.textColor = .black
        designViewController.titleTextView.text = "Quote by \(selectedQuote.author)"
    }

    func resetSearchResults() {
        quotes.removeAll()
        loadMoreResultsButton.setTitle("Load More Results", for: .normal)
        loadMoreResultsButton.isEnabled = false
        self.noResultsView.isHidden = true
        tableView.reloadData()
    }

    /// Receives an error object and handles UI feedback accordingly
    private func handleError(_ error: NSError) {
        DispatchQueue.main.async {
            switch error {
            case Constants.Errors.noQuotesFound:
                self.doneButton.isEnabled = false
                self.noResultsView.isHidden = false
                self.activityIndicator.stopAnimating()
            default: self.showAlertFor(error: error)
            }
        }
    }

    /// Displays an alert to the user with details about the error
    fileprivate func showAlertFor(error: NSError) {
        var err = error
        if Constants.Errors.networkErrorCodes.contains(error.code) {
            err = Constants.Errors.noNetwork
        }
        let alertController = UIAlertController(title: err.domain, message: err.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            alertController.dismiss(animated: true, completion:{})
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion:nil)
        }

}

// MARK: - UISearchBar

extension PaperQuotesViewController : UISearchBarDelegate {
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
        self.activityIndicator.startAnimating()
        paperQuotesClient.fetchQuotesForTags(searchText, completionHandler: {
            error, searchManager, quotes  in
            guard error == nil else {
                self.handleError(error!)
                return
            }

            self.quoteSearchManager = searchManager
            self.quotes = quotes!

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.doneButton.isEnabled = true
                self.tableView.reloadData()
                // If nextUrl is available, enable the load more results button
                if self.quoteSearchManager.nextUrl != nil {
                    self.loadMoreResultsButton.isEnabled = true
                }
            }
        })

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel button was clicked")
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableView

extension PaperQuotesViewController : UITableViewDelegate, UITableViewDataSource {
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
            cell.detailTextLabel!.text = quote.author
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuote = quotes[indexPath.row]
        designViewController.selectedQuote = selectedQuote
    }
}
