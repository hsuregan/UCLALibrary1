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
    let ID: String?
    
    var operatingHoursForDay: [String : OperatingHours] = [String : OperatingHours]()

    //custom properties
    var dataLastRetrieved: NSTimeInterval
    
    init(name: String, ID: String, code: String) {
        self.name = name
        self.ID = ID
        self.code = code
        dataLastRetrieved = 0
    }
}