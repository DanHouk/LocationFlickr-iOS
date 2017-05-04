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
    var server: String!
    var thumbnail: UIImage?
    var fullImage: UIImage?
    
    func getImageURL(_ imageType: String) -> URL {
        return URL(string: "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_\(imageType).jpg")!
    }
    
    init () { }
    
    init (photoId: String, passedFarm: Int, passedServer: String, passedSecret: String) {
        self.id = photoId
        self.farm = passedFarm
        self.server = passedServer
        self.secret = passedSecret
    }
}
