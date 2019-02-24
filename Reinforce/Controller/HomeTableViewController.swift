//
//  HomeTableViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 15/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var fetchedResultsController : NSFetchedResultsController<Reminder>!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        configureFetchedResultsControllerAndFetch()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()

    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = fetchedResultsController.fetchedObjects?.count else {
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


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
        return UIImage(named: "home_notification")
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


extension HomeTableViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
