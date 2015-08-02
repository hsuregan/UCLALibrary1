//
//  LibraryDetailViewController.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import AFNetworking
import SwiftyJSON
import UIKit

class LibraryDisplayViewController: UIViewController {
    
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var verticalScrollViewContentView: UIView!
    
    @IBOutlet weak var horizontalScrollView: UIScrollView!

    let libraryDataBaseURL = "http://webservices.library.ucla.edu/libservices/hours/unit/"
    let manager = AFHTTPRequestOperationManager()
    
    var library: Library!
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.mainScreen().bounds.size.width
        let height = verticalScrollViewContentView.frame.height
        verticalScrollView.contentSize =  CGSize(width: width, height: height)
        
        if let title = self.library.name, libraryID = self.library.ID {
            self.title = title
        }
        
        if let libraryID = self.library.ID {
            sendRequestToURLWithString(libraryDataBaseURL + String(libraryID))
        }
        
        //set custom back button for navigation bar
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("unwindToLibraryListView:"))
        backButton.image = UIImage(named: "backArrow")
        self.navigationItem.leftBarButtonItem = backButton
        
        
        //get data from Libraries.plist
        var libraries = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Libraries", ofType: "plist")!)
        if let ID = self.library.ID {
            let library = libraries?.objectForKey(ID) as! NSDictionary
            let imageName = library.objectForKey("imageName") as! String
            let longitude = library.objectForKey("longitude") as! Float
            let latitude = library.objectForKey("latitude") as! Float
            
//            libraryImageView.image = UIImage(named: imageName)
        } else {
            println("\(self.library.name) does not have a code")
            EXIT_FAILURE
        }
        

    }
    
    func unwindToLibraryListView(sender: UIButton!) {
        performSegueWithIdentifier("unwindFromLibraryDisplayViewController", sender: self)
    }
    
    // MARK: AFNetworking
    func sendRequestToURLWithString(URL: String) {
        manager.GET(URL, parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let json = JSON(response)
                let schedule = json["unitSchedule"]
                
                var formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
                
                let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                let responseOpenKeys = ["monThursOpens", "monThursOpens", "monThursOpens", "monThursOpens", "friOpens", "satOpens", "sunOpens"]
                let responseCloseKeys = ["monThursCloses", "monThursCloses", "monThursCloses", "monThursCloses", "friCloses", "satCloses", "sunCloses"]

                for index in 0..<daysOfWeek.count {
                    let openingTime = formatter.dateFromString(schedule[responseOpenKeys[index]].string ?? "")
                    let closingTime = formatter.dateFromString(schedule[responseCloseKeys[index]].string ?? "")
                    let operatingHours = OperatingHours(opens: openingTime, closes: closingTime)
                    self.library.operatingHoursForDay[daysOfWeek[index]] = operatingHours
                }
                
//                self.library.operatingHoursForDay["Monday"] = formatter.dateFromString(schedule["monThursOpens"].string ?? "")
//                self.library.operatingHoursForDay["Tuesday"].opens = formatter.dateFromString(schedule["monThursOpens"].string ?? "")
//                self.library.operatingHoursForDay["Wednesday"].opens  = formatter.dateFromString(schedule["monThursOpens"].string ?? "")
//                self.library.operatingHoursForDay["Thursday"].opens  = formatter.dateFromString(schedule["monThursOpens"].string ?? "")
//                self.library.operatingHoursForDay["Friday"].opens  = formatter.dateFromString(schedule["friOpens"].string ?? "")
//                self.library.operatingHoursForDay["Saturday"].opens  = formatter.dateFromString(schedule["satOpens"].string ?? "")
//                self.library.operatingHoursForDay["Sunday"].opens  = formatter.dateFromString(schedule["sunOpens"].string ?? "")
//                
//                self.library.operatingHoursForDay["Monday"].closes = formatter.dateFromString(schedule["monThursCloses"].string ?? "")
//                self.library.operatingHoursForDay["Tuesday"].closes = formatter.dateFromString(schedule["monThursCloses"].string ?? "")
//                self.library.operatingHoursForDay["Wednesday"].closes = formatter.dateFromString(schedule["monThursCloses"].string ?? "")
//                self.library.operatingHoursForDay["Thursday"].closes = formatter.dateFromString(schedule["monThursCloses"].string ?? "")
//                self.library.operatingHoursForDay["Friday"].closes = formatter.dateFromString(schedule["friCloses"].string ?? "")
//                self.library.operatingHoursForDay["Saturday"].closes = formatter.dateFromString(schedule["satCloses"].string ?? "")
//                self.library.operatingHoursForDay["Sunday"].closes = formatter.dateFromString(schedule["sunCloses"].string ?? "")
                
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["monThursClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["monThursClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["monThursClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["monThursClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["friClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["satClosed"].string?.toBool()
//                self.library.operatingHoursForDay["Monday"]?.opens = schedule["sunClosed"].string?.toBool()
//                
//                self.library.tuesNote = schedule["monThursNote"].string
//                self.library.tuesNote = schedule["monThursNote"].string
//                self.library.tuesNote = schedule["monThursNote"].string
//                self.library.tuesNote = schedule["monThursNote"].string
//                self.library.friNote = schedule["friNote"].string
//                self.library.satNote = schedule["satNote"].string
//                self.library.sunNote = schedule["sunNote"].string
                
                self.setupScrollView()
                println("success")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: implement failure condition
                println("failure: error \(error)")
        })
    }
    
    func setupScrollView() {
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var calendar = NSCalendar.currentCalendar()
        var offset: CGFloat = 0
        
        for day in daysOfWeek{
            let openTime = self.library.operatingHoursForDay[day]?.opens
            let openTimeComponents = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: openTime ?? NSDate())
            
            let closeTime = self.library.operatingHoursForDay[day]?.closes
            let closeTimeComponents = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: closeTime ?? NSDate())
            
            var libraryHoursView = LibraryHoursView()
            libraryHoursView.dayOfTheWeekLabel.text = day
            libraryHoursView.openingTimeLabel.text = "\(openTimeComponents.hour):\(openTimeComponents.minute)"
            libraryHoursView.closingTimeLabel.text = "\(closeTimeComponents.hour):\(closeTimeComponents.minute)"
            
            libraryHoursView.frame.origin = CGPoint(x: offset * libraryHoursView.frame.origin.x, y: libraryHoursView.frame.origin.y)
            
            
            horizontalScrollView.addSubview(libraryHoursView)
            offset++
            horizontalScrollView.contentSize = CGSize(width: libraryHoursView.frame.size.width * offset, height: libraryHoursView.frame.size.height)
            
        }
        

    }
}



//var calendar = NSCalendar.currentCalendar()
//var components = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: date!)
//
//var day = components.day
//var month = components.month
//var year = components.year
//var hour = components.hour
//var mimute = components.minute