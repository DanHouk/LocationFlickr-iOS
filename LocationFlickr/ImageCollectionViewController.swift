//
//  ImageCollectionViewController.swift
//  LocationFlickr
//
//  Created by Administrator on 8/12/15.
//  Copyright (c) 2015 houkcorp. All rights reserved.
//

import UIKit
import CoreLocation

let reuseIdentifier = "FlickrImageCell"

class ImageCollectionViewController: UICollectionViewController, CLLocationManagerDelegate, XMLParserDelegate {
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var photos: [FlickrImage] = []
    var flickrImage: FlickrImage?
    var photosData = PhotosData()
    var locationManager: CLLocationManager!
    var long: CLLocationDegrees!
    var lat: CLLocationDegrees!
    var imageViewParser: XMLParser!
    var tempFlickrImageDictionary: [String: String]! = Dictionary()
    var pageNumber = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.title = "Location Flickr"
        
        fetchAllImages()

        // Do any additional setup after loading the view.
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> FlickrImage {
        return photos[indexPath.row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //TODO: Need to put this back when time
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destinationViewController as? ImageViewController
        detailViewController?.setFlickrImage(flickrImage!)
    }*/

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        
        let flickrImageAtIndex = photoForIndexPath(indexPath)
        
        cell.imageView.image = nil
        
        if(flickrImageAtIndex.thumbnail != nil) {
            cell.imageView.image = flickrImageAtIndex.thumbnail
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        flickrImage = photoForIndexPath(indexPath)
    }
    
    func fetchAllImages() {
        let longString = String(stringInterpolationSegment: self.long)
        let longDouble = (longString as NSString).doubleValue
        let latString = String(stringInterpolationSegment: self.lat)
        let latDouble = (latString as NSString).doubleValue
        var urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&name=value&api_key=535b54e75b084504069f7b66d8bfb7c7&format=json&nojsoncallback=1&per_page=20&bbox=" + String(format: "%f", (longDouble - 0.2)) + "," + String(format: "%f", (latDouble - 0.2)) + "," + String(format: "%f", (longDouble + 0.2)) + "," + String(format: "%f", (latDouble + 0.2))
        urlString = urlString + "&page=" + String(pageNumber)
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        
        let operationQue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: operationQue) { response, data, error -> Void in
            if(error != nil) {
                NSLog("Main Image View Controller", error?.localizedDescription ?? "No message returned.")
                return
            }
            
            do {
                let results = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                let photosContainer = results["photos"] as! NSDictionary
                let photosReceived = photosContainer["photo"] as! [NSDictionary]
                
                for photo in photosReceived {
                    let photoID = photo["id"] as? String ?? ""
                    let farm = photo["farm"] as? Int ?? 0
                    let server = photo["server"] as? String ?? ""
                    let secret = photo["secret"] as? String ?? ""
                    
                    let flickrImage = FlickrImage(photoId: photoID, passedFarm: farm, passedServer: server, passedSecret: secret)
                    
                    let imageData = try? Data(contentsOf: flickrImage.getImageURL("t"))
                    flickrImage.thumbnail = UIImage(data: imageData!)
                    
                    self.photos.append(flickrImage)
                }
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData();
                    self.pageNumber = self.pageNumber + 1
                    self.fetchAllImages()
                })
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locationManager.location!.coordinate
        
        self.long = location.longitude
        self.lat = location.latitude
        
        locationManager.stopUpdatingLocation()
    }
}
