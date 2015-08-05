//
//  LibraryDetailViewController.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

let secondsInDay = 60 * 60 * 24

import UIKit

class LibraryDisplayViewController: UIViewController {
    
    var library: Library!
    
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var verticalScrollViewContentView: UIView!
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = library.name
        
        setupVerticalScrollView()
        setupHorizontalScrollView()
        setupNavigationBar()
    }
    
    func setupVerticalScrollView() {
        let width = Utility.screenSize().width
        let height = verticalScrollViewContentView.frame.height
        verticalScrollView.contentSize =  CGSize(width: width, height: height)
    }
    
    func timeIntervalToMonday() -> NSTimeInterval {
        let today = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE";
        var dayName = dateFormatter.stringFromDate(today)
        
        let daysFromMonday: Int
        switch (dayName) {
        case "Monday":
            daysFromMonday = 0
        case "Tuesday":
            daysFromMonday = 1
        case "Wednesday":
            daysFromMonday = 2
        case "Thursday":
            daysFromMonday = 3
        case "Friday":
            daysFromMonday = 4
        case "Saturday":
            daysFromMonday = 5
        case "Sunday":
            daysFromMonday = 6
        default:
            daysFromMonday = 0
        }
        return NSTimeInterval(secondsInDay * -daysFromMonday)
    }
    
    func setupHorizontalScrollView() {
        let count = library.operatingHours?.count ?? 0
        
        let calendar = NSCalendar.currentCalendar()
        for index in 0..<count {
            
            // CONote: using timeIntervalToMonday() to get the date for Monday because the UCLA webserivices
            // API (as of August 4 2015) only responds with the library times in chunks starting on Monday
            // and ending on Sunday
            let date = NSDate(timeIntervalSinceNow: NSTimeInterval(Int(timeIntervalToMonday()) + index * secondsInDay))
            let components = calendar.components(.CalendarUnitDay, fromDate: date)
            let dayNumber = components.day

            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE";
            var dayName = dateFormatter.stringFromDate(date)
            
            var openingTime = "LIBRARY"
            var closingTime = "CLOSED"
            if let opens = library.operatingHours?[index].opens, closes = library.operatingHours?[index].closes {
                openingTime = NSDateFormatter.localizedStringFromDate(opens, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                closingTime = NSDateFormatter.localizedStringFromDate(closes, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            }
            
            var view = LibraryHoursView()
            view.frame.origin = CGPoint(x: CGFloat(index) * view.frame.width, y: 0)
            view.dayOfTheWeekLabel.text = dayName
            view.dateLabel.text = String(dayNumber)
            view.openingTimeLabel.text = openingTime
            view.closingTimeLabel.text = closingTime
            
            horizontalScrollView.addSubview(view)
        }
        
        let viewSize = LibraryHoursView().frame.size
        let width = viewSize.width * CGFloat(count)
        let height = viewSize.height
        horizontalScrollView.contentSize = CGSize(width: width, height: height)
    }
    
    func setupNavigationBar() {
        var backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("unwindToLibraryListView:"))
        backButton.image = UIImage(named: "backArrow")
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: Navigation
    func unwindToLibraryListView(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
