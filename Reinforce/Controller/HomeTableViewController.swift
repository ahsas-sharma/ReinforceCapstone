//
//  HomeTableViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 15/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class HomeTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var fetchedResultsController : NSFetchedResultsController<Reminder>!
    var isEmptyTable: Bool = true
    @IBOutlet weak var editButton: UIBarButtonItem!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetchedResultsControllerAndFetch()

        // Add logo to title view
        let logo = UIImage(named:"splash_bell")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()

    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fetchedResultsController.fetchedObjects?.count else {
            editButton.isEnabled = false
            return 0
        }
        return count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.Cells.homeTableViewCell, for: indexPath) as! HomeTableViewCell
        if fetchedResultsController.hasObject(at: indexPath) {
            let reminder = fetchedResultsController.object(at: indexPath)
            cell.reminder = reminder
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteReminderAtIndexPath(indexPath)
        }
    }

    // MARK: - IBAction

    @IBAction  func editButtonTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        tableView.isEditing ? (editButton.title = "Done") : (editButton.title = "Edit")
    }


    // MARK: - Helper

    /// Prepares the fetchedResultsController to fetch Reminder objects, sorted by the createdAt attribute and perform the fetch.
    fileprivate func configureFetchedResultsControllerAndFetch() {
        let fetchRequest : NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending : false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error while trying to perform fetch")
        }
    }

    /// Handles the safe deletion of of a reminder object and its associated request objects after cancelling its pending notifications
    /// - Parameters:
    ///     - indexPath : path of the row containing the reminder object to delete
    fileprivate func deleteReminderAtIndexPath(_ indexPath: IndexPath) {
        let reminder = fetchedResultsController.object(at: indexPath)
        let notificationRequests = reminder.requests?.allObjects as! [Request]
        var savedIdentifiers = [String]()
        guard !notificationRequests.isEmpty else {
            print("Could not find any notification requests for the given object.")
            return
        }

        for request in notificationRequests {
            if let identifier = request.identifier?.uuidString {
                print("Object Request identifier: \(identifier)")
                savedIdentifiers.append(identifier)
            }
        }
        var pendingRequestIdentifiers = [String]()

        // Get list of current pending notification requests and filter the ones related to the Reminder object facing deletion.
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
            requests in
            for request in requests {
                if savedIdentifiers.contains(request.identifier) {
                    pendingRequestIdentifiers.append(request.identifier)
                }
            }
        })

        // Remove notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pendingRequestIdentifiers)

        for request in notificationRequests {
            let object = dataController.viewContext.object(with: request.objectID)
            dataController.viewContext.delete(object)
            print("Deleted a request object")
        }
        dataController.viewContext.delete(reminder)
        do {
            try dataController.viewContext.save()
        } catch {
            print("There was an error while trying to save the view context.")
        }
    }

    // MARK: - DZNEmptyDataSet

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Reinforce"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Create beautiful personalized reminders with famous quotes, stunning photos and custom notifications."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Design a notification"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        performSegue(withIdentifier: Constants.Identifiers.newDesignSegue, sender: nil)
    }

}


// MARK: - FetchedResultsController Delegate
extension HomeTableViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete {
            print("deleting tableview row")
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        }
        if type == .insert {
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // If it's the first item, reload tableview to hide the emptyDataSet view.
        if isEmptyTable {
            tableView.reloadData()
            isEmptyTable = false
        }

        if controller.fetchedObjects!.isEmpty {
            self.editButton.title = "Edit"
            isEmptyTable = true
            tableView.reloadData()
        }
    }
}
