//
//  ImageViewController.swift
//  LocationFlickr
//
//  Created by Daniel Houk on 8/13/15.
//  Copyright (c) 2015 houkcorp. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageImageView: UIImageView!
    
    var flickrImage: FlickrImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadfullImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFlickrImage(flickrImage: FlickrImage) {
        self.flickrImage = flickrImage
    }
    
    func loadfullImage() -> Void {
        let url = self.flickrImage.getImageURL("z")
        let urlRequest = NSURLRequest(URL: url)
        let operationQue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: operationQue) { response, data, error -> Void in
            if(error != nil) {
                NSLog("Main Image View Controller", error!)
                
                return
            }
            
            if(data != nil) {
                self.flickrImage.fullImage = UIImage(data: data!)
                self.imageImageView.image = self.flickrImage.fullImage
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}