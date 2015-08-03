//
//  ViewController.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import UIKit

class LibraryListViewController: UIViewController {
    
    let dataManager = DataManager()
    
    var libraries: [Library]?
    
    @IBOutlet weak var librariesTableView: UITableView!
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataManager.dataForLibraries()
        
        librariesTableView.dataSource = self
        librariesTableView.delegate = self
        librariesTableView.layer.cornerRadius = 5
        librariesTableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "processLibraryListData:", name: "LibraryListDataReady", object: nil)
        notificationCenter.addObserver(self, selector: "processLibraryData:", name: "LibraryDataReady", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: "LibraryListDataReady", object: nil)
        notificationCenter.removeObserver(self, name: "LibraryDataReady", object: nil)
    }
    
    
    // MARK: Notifications
    func processLibraryListData(notification: NSNotification) {
        let data = notification.userInfo!
        let libraries: AnyObject = data["data"]!
        self.libraries = (libraries as! [Library])
        librariesTableView.reloadData()
    }
    
    func processLibraryData(notification: NSNotification) {
        let data = notification.userInfo!
        let operatingHoursData = data["data"] as! OperatingHoursData
        let operatingHours = operatingHoursData.operatingHours
        let ID = operatingHoursData.ID
        
        let predicate = NSPredicate(format: "ID == %@", ID)
        var library = (libraries! as NSArray).filteredArrayUsingPredicate(predicate)
        if let library = library.first as? Library {
            library.operatingHours = operatingHours
            librariesTableView.reloadData()
        }
    }
    
    // MARK: Navigation 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLibraryDisplayViewController" {
            var destination = segue.destinationViewController as! LibraryDisplayViewController
            var indexPath = self.librariesTableView.indexPathForSelectedRow()
            destination.library = libraries?[(indexPath?.row)!]
        }
    }
}

// MARK: UITableViewDataSource
extension LibraryListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("libraryListCell") as! LibraryListTableViewCell
        let library = libraries?[indexPath.row]
        
        cell.libraryNameLabel.text = library?.name ?? ""
        
        if let operatingHours = library?.operatingHours {
            let opens = operatingHours[0].opens
            let closes = operatingHours[0].closes
            
            if let opens = opens, closes = closes {
                cell.libraryHoursLabel.text = "\(opens) - \(closes)"
            } else {
                cell.libraryHoursLabel.text = "Hours not available"
            }
            
        } else {
            self.dataManager.dataForLibraryWithID(library!.ID)
            cell.libraryHoursLabel.text = ""
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension LibraryListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

