//
//  DataManager.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 8/2/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import Foundation
import AFNetworking
import SwiftyJSON

class OperatingHoursData {
    var ID: String
    var operatingHours: [OperatingHours]
    
    init(ID: String, operatingHours: [OperatingHours]) {
        self.ID = ID
        self.operatingHours = operatingHours
    }
}

class DataManager {
    
    let unitURL = "http://webservices.library.ucla.edu/libservices/units"
    let baseDataURL = "http://webservices.library.ucla.edu/libservices/hours/unit/"
    let manager = AFHTTPRequestOperationManager()
    
    var libraries: [Library]?
    
    func dataForLibraries() {
        if let libraries = self.libraries {
            postNotification("LibraryListDataReady", data: self.libraries)
        } else {
            fetchLibraryUnitDataFromNetwork()
        }
    }
    
    func dataForLibraryWithID(ID: String) {
        
        //get library with ID, check if operating hours are non-null
        let predicate = NSPredicate(format: "ID == %@", ID)
        let libraries = (self.libraries! as NSArray).filteredArrayUsingPredicate(predicate)
        
        if let library = libraries.first as? Library {
            if let operatingHours = library.operatingHours {
                var operatingHoursData = OperatingHoursData(ID: ID, operatingHours: operatingHours)
                self.postNotification("LibraryDataReady", data: operatingHoursData)
            } else {
                fetchLibraryDataFromNetwork(ID)
            }
        }
        
    }
    
    // MARK: Notifications
    func postNotification(name: String, data: AnyObject?) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let notification: NSNotification
        if let data: AnyObject = data {
            let userInfo = NSDictionary(object: data, forKey: "data") as [NSObject : AnyObject]
            notification = NSNotification(name: name, object: nil, userInfo: userInfo)
        } else {
            notification = NSNotification(name: name, object: nil, userInfo: nil)
        }
        notificationCenter.postNotification(notification)
    }
    
    //MARK: AFNetworking
    private func fetchLibraryUnitDataFromNetwork() {
        manager.GET(unitURL, parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let json = JSON(response)
                var libraryData = json["unit"]
                for index in 0..<libraryData.count {
                    let name = libraryData[index]["name"].string
                    let ID = libraryData[index]["id"].string
                    if let name = name, ID = ID {
                        var library = Library(name: name, ID: ID)
                        if self.libraries == nil {
                            self.libraries = [Library]()
                        }
                        self.libraries!.append(library)
                    }
                }
                
                self.postNotification("LibraryListDataReady", data: self.libraries)
                println("unit success")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: implement failure condition
                println("failure: error \(error)")
        })
    }
    
    private func fetchLibraryDataFromNetwork(ID: String) {
        manager.GET(baseDataURL + ID, parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let json = JSON(response)
                let schedule = json["unitSchedule"]
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"

                var timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                
                let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                let responseOpenKeys = ["monThursOpens", "monThursOpens", "monThursOpens", "monThursOpens", "friOpens", "satOpens", "sunOpens"]
                let responseCloseKeys = ["monThursCloses", "monThursCloses", "monThursCloses", "monThursCloses", "friCloses", "satCloses", "sunCloses"]
                
                var operatingHours = [OperatingHours]()
                for index in 0..<daysOfWeek.count {
                    let openingDate = dateFormatter.dateFromString(schedule[responseOpenKeys[index]].string ?? "")
                    let closingDate = dateFormatter.dateFromString(schedule[responseCloseKeys[index]].string ?? "")
                    
                    let openingTime: String
                    let closingTime: String
                    
                    openingDate == nil ? (openingTime = "") : (openingTime = NSDateFormatter.localizedStringFromDate(openingDate!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))

                    closingDate == nil ? (closingTime = "") : (closingTime = NSDateFormatter.localizedStringFromDate(closingDate!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))
                    
                    
                    let hours = OperatingHours(day: daysOfWeek[index], opens: openingTime, closes: closingTime)
                    operatingHours.append(hours)
                }
                
                let predicate = NSPredicate(format: "ID == %@", ID)
                let library = (self.libraries! as NSArray).filteredArrayUsingPredicate(predicate)
                if let library = library.first as? Library{
                    library.operatingHours = operatingHours
                }
                
                var operatingHoursData = OperatingHoursData(ID: ID, operatingHours: operatingHours)
                self.postNotification("LibraryDataReady", data: operatingHoursData)
                
                println("success")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: implement failure condition
                println("failure: error \(error)")
        })
    }
}