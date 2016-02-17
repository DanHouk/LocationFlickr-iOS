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

class ImageCollectionViewController: UICollectionViewController, CLLocationManagerDelegate, NSXMLParserDelegate {
    var photos = [FlickrImage]()
    var flickrImage = FlickrImage()
    var photosData = PhotosData()
    var locationManager: CLLocationManager!
    var long: CLLocationDegrees!
    var lat: CLLocationDegrees!
    var imageViewParser: NSXMLParser!
    var tempFlickrImageDictionary: [String: String]! = Dictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
        fetchAllImages()

        // Do any additional setup after loading the view.
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrImage {
        return photos[indexPath.row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let detailViewController = segue.destinationViewController as? ImageViewController
        detailViewController?.setFlickrImage(flickrImage)
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let flickrImageAtIndex = photoForIndexPath(indexPath)
        
        self.loadThumbnail(flickrImageAtIndex) {
            returnedFlickrImage, error in
            if(error != nil) {
                NSLog("Main Image View Controller", error!)
                
                return
            }
            
            cell.imageView.image = flickrImageAtIndex.thumbnail
        }
        
        if(flickrImageAtIndex.thumbnail != nil) {
            cell.imageView.image = flickrImageAtIndex.thumbnail
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        flickrImage = photoForIndexPath(indexPath)
    }
    
    func fetchAllImages() {
        let longString = String(stringInterpolationSegment: self.long)
        let longDouble = (longString as NSString).doubleValue
        let latString = String(stringInterpolationSegment: self.lat)
        let latDouble = (latString as NSString).doubleValue
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&name=value&api_key=535b54e75b084504069f7b66d8bfb7c7&bbox=" + String(format: "%f", (longDouble - 0.2)) + "," + String(format: "%f", (latDouble - 0.2)) + "," + String(format: "%f", (longDouble + 0.2)) + "," + String(format: "%f", (latDouble + 0.2))
        let url: NSURL! = NSURL(string: urlString)
        let urlRequest:NSURLRequest = NSURLRequest(URL: url)
        let operationQue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: operationQue) { response, data, error -> Void in
            if(error != nil) {
                NSLog("Main Image View Controller", error!)
                return
            }
            
            self.imageViewParser = NSXMLParser(data: data!)
            self.imageViewParser.delegate = self;
            self.imageViewParser.parse()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = locationManager.location!.coordinate
        
        self.long = location.longitude
        self.lat = location.latitude
        
        locationManager.stopUpdatingLocation()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if(elementName == "photos") {
            if(attributeDict.count > 0) {
                for(key, value) in attributeDict {
                    if(key == "page") {
                        photosData.page = Int(value)
                    }
                    
                    if(key == "pages") {
                        photosData.pages = Int(value)
                    }
                    
                    if(key == "perpage") {
                        photosData.perPage = Int(value)
                    }
                    
                    if(key == "total") {
                        photosData.total = Int(value)
                    }
                }
                print("GOt to here.")
            }
        }
        
        if(elementName == "photo") {
            if(attributeDict.count > 0) {
                let tempFlickrImage = FlickrImage()
                for(key, value) in attributeDict {
                    if(key == "farm") {
                        tempFlickrImage.farm = Int(value)
                    }
                    
                    if(key == "id") {
                        tempFlickrImage.id = String(value)
                    }
                    
                    if(key == "secret") {
                        tempFlickrImage.secret = String(value)
                    }
                    
                    if(key == "server") {
                        tempFlickrImage.server = Int(value)
                    }
                }
                
                photos.append(tempFlickrImage)
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        print("Entered found characters parser")
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("Entered did end element parser");
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
    }
    
    func loadThumbnail(passedFlickrImage: FlickrImage, completion: (flickrImage:FlickrImage, error: NSError?) -> Void) {
        let url = passedFlickrImage.getImageURL("t")
        let urlRequest = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if(error != nil) {
                NSLog("Main Image View Controller", error!)
                completion(flickrImage: passedFlickrImage, error: error)
                
                return
            }
            
            if(data != nil) {
                passedFlickrImage.thumbnail = UIImage(data: data!)
                completion(flickrImage: passedFlickrImage, error: nil)
                
                return
            }
            
            completion(flickrImage: passedFlickrImage, error: nil)
        }
    }
}