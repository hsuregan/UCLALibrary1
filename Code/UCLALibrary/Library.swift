//
//  Library.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import Foundation

struct OperatingHours {
    var closes: NSDate?
    var opens: NSDate?
    
    init(opens: NSDate?, closes: NSDate?) {
        self.opens = opens
        self.closes = closes
    }
}

class Library {
    let code: String?
    let name: String?
    let ID: Int?
    
    var operatingHoursForDay: [String : OperatingHours] = [String : OperatingHours]()
    
    
//    var monClosed: Bool?
//    var monCloses: NSDate?
//    var monOpens: NSDate?
//    var monNote: String?
//    
//    var tuesClosed: Bool?
//    var tuesCloses: NSDate?
//    var tuesOpens: NSDate?
//    var tuesNote: String?
//    
//    var wedClosed: Bool?
//    var wedCloses: NSDate?
//    var wedOpens: NSDate?
//    var wedNote: String?
//    
//    var thursClosed: Bool?
//    var thursCloses: NSDate?
//    var thursOpens: NSDate?
//    var thursNote: String?
//    
//    var friClosed: Bool?
//    var friCloses: NSDate?
//    var friOpens: NSDate?
//    var friNote: String?
//    
//    var satClosed: Bool?
//    var satCloses: NSDate?
//    var satOpens: NSDate?
//    var satNote: String?
//
//    var sunClosed: Bool?
//    var sunCloses: NSDate?
//    var sunOpens: NSDate?
//    var sunNote: String?

    //custom properties
    var dataLastRetrieved: NSTimeInterval
    
    init(name: String, ID: Int, code: String) {
        self.name = name
        self.ID = ID
        self.code = code
        dataLastRetrieved = 0
    }
}