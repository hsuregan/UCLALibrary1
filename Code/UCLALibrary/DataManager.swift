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

//wrapper which provides unique way (ID) to lookup libraries in other VCs
class OperatingHoursData {
    var ID: String
    var operatingHours: [OperatingHours]
    
    init(ID: String, operatingHours: [OperatingHours]) {
        self.ID = ID
        self.operatingHours = operatingHours
    }
}

class DataManager {
    
    private let unitURL = "http://webservices.library.ucla.edu/libservices/units"
    private let baseDataURL = "http://webservices.library.ucla.edu/libservices/hours/unit/"
    private let manager = AFHTTPRequestOperationManager()
    
    //cache
    private var libraries: [Library]?
   
    // MARK: DataManagerAPI
    func dataForLibraries() {
        if let libraries = self.libraries {
            postNotification("LibraryListDataReady", data: self.libraries)
        } else {
            fetchLibraryUnitDataFromNetwork()
        }
    }
    
    func dataForLibraryWithID(ID: String) {
        self.libraries?.filter { (element: Library) -> Bool in
            if element.ID == ID {
                if let operatingHours = element.operatingHours {
                    var operatingHoursData = OperatingHoursData(ID: ID, operatingHours: operatingHours)
                    self.postNotification("LibraryDataReady", data: operatingHoursData)
                } else {
                    self.fetchLibraryDataFromNetwork(ID)
                }
            }
            return false
        }
    }
    
    // MARK: Notifications
    private func postNotification(name: String, data: AnyObject?) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let notification: NSNotification
        if let data: AnyObject = data {
            let userInfo = ["data" : data]
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
                self.libraries = [Library]()
                for index in 0..<libraryData.count {
                    let name = libraryData[index]["name"].string
                    let ID = libraryData[index]["id"].string
                    if let name = name, ID = ID {
                        var library = Library(name: name, ID: ID)
                        self.libraries!.append(library)
                    }
                }
                
                self.postNotification("LibraryListDataReady", data: self.libraries)
                self.fetchAllLibraryData()
                println("unit success")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: implement failure condition
                println("failure: error \(error)")
        })
    }
    
    private func fetchAllLibraryData() {
        if let libraries = libraries {
            for library in libraries {
                fetchLibraryDataFromNetwork(library.ID)
            }
        }
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
                    let hours = OperatingHours(day: daysOfWeek[index], opens: openingDate, closes: closingDate)
                    operatingHours.append(hours)
                }
                
                self.libraries = self.libraries?.map { (element: Library) -> Library in
                    if element.ID == ID {
                        element.operatingHours = operatingHours
                    }
                    return element
                }
                
                var operatingHoursData = OperatingHoursData(ID: ID, operatingHours: operatingHours)
                self.postNotification("LibraryDataReady", data: operatingHoursData)
                println("success for \(ID)")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: implement failure condition
                println("failure: error \(error)")
        })
    }
}