//
//  FlickrImage.swift
//  LocationFlickr
//
//  Created by Administrator on 8/12/15.
//  Copyright (c) 2015 houkcorp. All rights reserved.
//

import UIKit

class FlickrImage {
    var farm: Int!
    var id: String!
    var secret: String!
    var server: Int!
    var thumbnail: UIImage?
    var fullImage: UIImage?
    
    func getImageURL(imageType: String) -> NSURL {
        return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(imageType).jpg")!
    }
}
