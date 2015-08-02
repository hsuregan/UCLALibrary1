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
        
        if let libraryName = library.name {
            self.title = library.name
        }
        sendRequestToURLWithString(libraryDataBaseURL + String(library.ID!))

        
        setupVerticalScrollView()
        setupHorizontalScrollView()
        setupNavigationBar()
        fetchDataFromPlist()
    }
    
    func setupHorizontalScrollView() {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var viewSize = LibraryHoursView().frame
        
        for (index, element) in enumerate(days) {
            var view = LibraryHoursView()
            view.frame.origin = CGPoint(x: CGFloat(index) * viewSize.width, y: 0)
            horizontalScrollView.addSubview(view)
        }
        horizontalScrollView.contentSize = CGSize(width: CGFloat(days.count) * viewSize.width, height: viewSize.height)
    }
    
    func setupVerticalScrollView() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = verticalScrollViewContentView.frame.height
        verticalScrollView.contentSize =  CGSize(width: width, height: height)
    }
    
    
    //set custom back button for navigation bar
    func setupNavigationBar() {
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("unwindToLibraryListView:"))
        backButton.image = UIImage(named: "backArrow")
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    //get data from Libraries.plist
    func fetchDataFromPlist() {
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
    
    // MARK: Navigation
    func unwindToLibraryListView(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
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
        
        
//        var view = LibraryHoursView()
//        view.frame.origin = CGPoint(x: 0, y: 0)
//        horizontalScrollView.addSubview(view)
//        
//        var viewB = LibraryHoursView()
//        viewB.frame.origin = CGPoint(x: view.frame.width, y: 0)
//        horizontalScrollView.addSubview(viewB)
//        
//        horizontalScrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
//        for day in daysOfWeek{
//            let openTime = self.library.operatingHoursForDay[day]?.opens
//            let openTimeComponents = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: openTime ?? NSDate())
//            
//            let closeTime = self.library.operatingHoursForDay[day]?.closes
//            let closeTimeComponents = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: closeTime ?? NSDate())
//            
//            var libraryHoursView = LibraryHoursView()
//            libraryHoursView.dayOfTheWeekLabel.text = day
//            libraryHoursView.openingTimeLabel.text = "\(openTimeComponents.hour):\(openTimeComponents.minute)"
//            libraryHoursView.closingTimeLabel.text = "\(closeTimeComponents.hour):\(closeTimeComponents.minute)"
//            
//            libraryHoursView.frame.origin = CGPoint(x: offset * libraryHoursView.frame.origin.x, y: libraryHoursView.frame.origin.y)
//            
//            
//            horizontalScrollView.addSubview(libraryHoursView)
//            offset++
//            horizontalScrollView.contentSize = CGSize(width: libraryHoursView.frame.size.width * offset, height: libraryHoursView.frame.size.height)
//            
//        }
        

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