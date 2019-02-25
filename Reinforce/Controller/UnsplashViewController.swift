//
//  UnsplashViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 20/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit
import CoreData

class UnsplashViewController : UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var loadMoreResultsButton: UIButton!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var unsplashClient = UnsplashClient()
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var nextUrlString: String?
    var blockOperation : BlockOperation!
    var lastIndexPath : IndexPath!
    var designViewController: DesignViewController!
    var selectedPhoto : Photo!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePhotoResultsControllerAndFetch()
        configureCollectionViewFlowLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBar.isHidden = false
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }


    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


    @IBAction func loadMoreResultsButtonTapped(_ sender: Any) {
        loadMoreResultsButton.isEnabled = false
        lastIndexPath = IndexPath(item: collectionView.numberOfItems(inSection: 0) - 1 , section: 0)
        activityIndicator.startAnimating()
        unsplashClient.searchPhotosByKeywords("", next: nextUrlString, completionHandler: {
            error, nextUrlString in
            guard error == nil else {
                self.handleError(error!)
                return
            }
            self.nextUrlString = nextUrlString
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
                self.nextUrlString != nil ? (self.loadMoreResultsButton.isEnabled = true) : (self.loadMoreResultsButton.isEnabled = false)
                self.collectionView.scrollToItem(at: self.lastIndexPath, at: .centeredVertically, animated: true)
            }
        })
    }

    // MARK: - Helper
    fileprivate func resetPhotoSearchResults(){
        guard let fetchedObjects = fetchedResultsController.fetchedObjects, fetchedObjects.count == 0 else {
            fetchedResultsController = nil
            dataController.deleteAllPhotos()
            configurePhotoResultsControllerAndFetch()
            collectionView.reloadData()
            return
        }

        nextUrlString = nil
        self.noResultsView.isHidden = true
        loadMoreResultsButton.isEnabled = false
    }

    /// Receives an error object and handles UI feedback accordingly
    private func handleError(_ error: NSError) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            switch error {
            case Constants.Errors.noPhotosFound:
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
extension UnsplashViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = fetchedResultsController.fetchedObjects?.count else {
            return 0
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.Cells.photoCollectionViewCell, for: indexPath) as! PhotoCollectionViewCell

        if fetchedResultsController.hasObject(at: indexPath) {
            cell.photo = fetchedResultsController.object(at: indexPath)
            if cell.photo.thumbImage != nil {
                cell.imageView.image = UIImage(data: cell.photo.thumbImage!)
            } else {
                cell.imageView.image = UIImage(named: "placeholder")
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // make sure photo exists for indexPath
        guard fetchedResultsController.hasObject(at: indexPath) else {
            return
        }
        let photo = fetchedResultsController.object(at: indexPath)
        self.selectedPhoto = photo
        let unsplashPhotoVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.unsplashPhotoViewController) as! UnsplashPhotoViewController
        unsplashPhotoVC.photo = photo
        unsplashPhotoVC.designViewController = self.designViewController
        self.navigationController?.pushViewController(unsplashPhotoVC, animated: true)
    }


    // Check if collectionview indexPath is valid
    fileprivate func collectionViewIndexPathIsValid(indexPath: IndexPath) -> Bool {
        return indexPath.section < numberOfSections(in: collectionView) && indexPath.row < collectionView.numberOfItems(inSection: indexPath.section)

    }

    /// Setup collectionview flow layout
    fileprivate func configureCollectionViewFlowLayout() {
        let space:CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}

extension UnsplashViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        resetPhotoSearchResults()

        guard let searchText = searchBar.text, searchText != "" else {
            return
        }

        activityIndicator.startAnimating()
        unsplashClient.searchPhotosByKeywords(searchText, next: nil, completionHandler: {
            error, nextUrlString in
            guard error == nil else {
                self.handleError(error!)
                return
            }
            self.nextUrlString = nextUrlString
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
                if self.nextUrlString != nil { self.loadMoreResultsButton.isEnabled = true }
            }
        })

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension UnsplashViewController : NSFetchedResultsControllerDelegate {

    /// Configure fetched results controller and perform fetch
    fileprivate func configurePhotoResultsControllerAndFetch() {

        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "addedOn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.includesPendingChanges = true

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.unsplashContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("FetchResultsController.performfetch crashed")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            DispatchQueue.main.async {
                if self.collectionViewIndexPathIsValid(indexPath: newIndexPath) {
                    self.collectionView?.reloadItems(at: [newIndexPath])
                } else {
                    self.collectionView.reloadData()
                }
            }
        case .update:
            guard let indexPath = indexPath else { break }
            DispatchQueue.main.async {
                if self.collectionViewIndexPathIsValid(indexPath: indexPath) {
                    self.collectionView?.reloadItems(at: [indexPath])
                } else {
                    self.collectionView.reloadData()
                }
            }
        default: ()
        }
    }
}

