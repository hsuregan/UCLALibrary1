//
//  Library.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import Foundation

class OperatingHours {
    var day: String
    var closes: String?
    var opens: String?
    
    init(day: String, opens: String?, closes: String?) {
        self.day = day
        self.opens = opens
        self.closes = closes
    }
}

class Library: NSObject {
    let name: String
    let ID: String
    
    let imageName: String
    let longitude: Float
    let latitude: Float
    
    var operatingHours: [OperatingHours]?
    var dataLastRetrieved: NSTimeInterval
    
    init(name: String, ID: String) {
        self.name = name
        self.ID = ID
        dataLastRetrieved = 0
        
        let libraries = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Libraries", ofType: "plist")!)
        let library = libraries?.objectForKey(ID) as! NSDictionary
        self.imageName = library.objectForKey("imageName") as! String
        self.longitude = library.objectForKey("longitude") as! Float
        self.latitude = library.objectForKey("latitude") as! Float
    }
}