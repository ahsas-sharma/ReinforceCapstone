//
//  UnsplashClient.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

class UnsplashClient : NSObject {

    var searchPhotosTask : URLSessionDataTask!
    var downloadThumbTask : URLSessionDataTask!
    var downloadFullImageTask : URLSessionDataTask!
    var downloadProfileImageTask : URLSessionDataTask!

    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    func searchPhotosByKeywords(_ keywords: String, next: String?, completionHandler: @escaping (_ error: NSError?, _ nextUrlString: String?) -> Void) {
        var url: URL!
        if next != nil {
            url = URL(string: next!)
        } else {
            url = constructUrl(query: keywords)
        }
        print("Launching request with url:\(String(describing: url))")

        let request = URLRequest(url: url)
        searchPhotosTask = URLSession.shared.dataTask(with: request) {
            data, response, error in

            guard error == nil else {
                debugPrint("Error : \(#function), \(#line), \(String(describing: error))")
                return
            }

            guard data != nil else {
                debugPrint("Error : \(#function), \(#line)")
                return
            }

            var nextUrlString: String?
            if let httpResponse = response as? HTTPURLResponse {
                nextUrlString = self.getNextUrlFromResponse(httpResponse)
            } else {
                print("Could not cast response as HTTPUrlResponse")
            }

            var parsedResult : AnyObject?
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            } catch {
                print("Error while parsing JSON")
            }

            guard let results = parsedResult?[Constants.Unsplash.resultsKey] as? [[String: AnyObject]] else {
                print("Could not load results")
                return
            }

            let photos = self.processResultsIntoPhotoObjects(results: results)
            completionHandler(nil, nextUrlString)
            self.downloadThumbnailsForPhotos(photos)
        }
        searchPhotosTask.resume()
    }

    private func processResultsIntoPhotoObjects(results: [[String: AnyObject]]) -> [Photo] {
        var photos = [Photo]()
        for result in results {

            let photo = Photo(context: dataController.unsplashContext)
            photo.addedOn = Date()

            if let urls = result[Constants.Unsplash.urlsKey] as? [String: AnyObject], let thumbUrl = urls[Constants.Unsplash.thumbUrlKey] as? String, let fullUrl = urls[Constants.Unsplash.fullUrlKey] as? String{

                photo.thumbUrl = thumbUrl
                photo.fullUrl = fullUrl
            }

            if let user = result[Constants.Unsplash.userKey] as? [String: AnyObject], let username = user[Constants.Unsplash.usernameKey] as? String, let name = user[Constants.Unsplash.nameKey] as? String, let profileImage = user[Constants.Unsplash.profileImageKey] as? [String: AnyObject], let profileImageUrl = profileImage[Constants.Unsplash.largeProfileImageKey] as? String {
                photo.username = username
                photo.name = name
                photo.profileImageUrl = profileImageUrl
            }
            print("Appended a new photo object: \(photo.objectID)")
            photos.append(photo)
        }

        // Save unsplash context
        do {
            try dataController.unsplashContext.save()
        } catch {
            print("Error while trying to save unsplash context")
        }

        print("Returning photos count: \(photos.count)")
        return photos
    }

    fileprivate func downloadThumbnailsForPhotos(_ photos: [Photo]) {
        for photo in photos {
            guard photo.thumbUrl != nil else {
                print("Could not find thumbUrl")
                continue
            }
            guard let url = URL(string: photo.thumbUrl!) else {
                print("Could not make url from thumbUrl")
                continue
            }

            downloadThumbTask = URLSession.shared.dataTask(with: url) {
                data, response, error in
                guard error == nil else {
                    print("Error while download thumbnail")
                    return
                }
                guard data != nil else {
                    print("Could not download any data")
                    return
                }
                print("Downloaded a thumb image")
                photo.thumbImage = data!

                do {
                    try self.dataController.unsplashContext.save()
                } catch {
                    print("Error while trying to save unsplash context")
                }

            }
            downloadThumbTask.resume()
        }
    }

    /// Parses through Link header in response and return a string for the next search URL.
    private func getNextUrlFromResponse(_ response: HTTPURLResponse) -> String? {
        if let linkHeader = response.allHeaderFields["Link"] as? String {
            let links = linkHeader.components(separatedBy: ",")

            var dictionary: [String: String] = [:]
            links.forEach({
                let components = $0.components(separatedBy:"; ")
                let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "< >"))
                dictionary[components[1]] = cleanPath
            })

            if let nextPagePath = dictionary["rel=\"next\""] {
                print("nextPagePath: \(nextPagePath)")
                return nextPagePath
            }
        }
        return nil
    }

    /// Takes in the query keyword and return a formatted URL to call Unsplash
    private func constructUrl(query: String) -> URL {
        let escapedQuery = formatQueryString(query)
        let urlString = Constants.Unsplash.baseUrl + Constants.Unsplash.clientIdKey + "=" + Constants.Unsplash.clientId + "&" + Constants.Unsplash.queryKey + "=" + escapedQuery + "&" + Constants.Unsplash.perPageKey + "=" + Constants.Unsplash.perPage
        let url = URL(string: urlString)!
        return url
    }

    /// Downloads a single profile image using the url given in the profileImageUrl attribute of the Photo object
    func downloadUserProfileImage(forPhoto photo: Photo, completionHandler: @escaping (_ error: Error?,_ data: Data?) -> Void) {

        guard let urlString = photo.profileImageUrl, let url = URL(string: urlString) else {
            return
        }

        downloadProfileImageTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard error == nil, data != nil else {
                completionHandler(error, nil)
                return
            }
            photo.profileImage = data
            self.dataController.saveUnsplashContext()
            completionHandler(nil, data)
        }
        downloadProfileImageTask.resume()
    }

    /// Downloads a high resolution image for the given Photo object using the fullImageUrl attribute
    func downloadFullResolutionImage(forPhoto photo: Photo, completionHandler: @escaping (_ error : Error?, _ data: Data?) -> Void) {

        guard let urlString = photo.fullUrl, let url = URL(string: urlString) else {
            return
        }

        downloadFullImageTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard error == nil, data != nil else {
                completionHandler(error, nil)
                return
            }

            photo.fullImage = data
            self.dataController.saveUnsplashContext()
            completionHandler(nil, data)
        }
        downloadFullImageTask.resume()
    }
}
