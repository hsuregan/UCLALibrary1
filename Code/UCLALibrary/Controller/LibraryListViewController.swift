//
//  ViewController.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

import AFNetworking
import SwiftyJSON
import UIKit

class LibraryListViewController: UIViewController {
    
    @IBOutlet weak var librariesTableView: UITableView!
    
    let manager = AFHTTPRequestOperationManager()
    let libraryUnitsURL = "http://webservices.library.ucla.edu/libservices/units"
    
    var libraries: [Library] = [Library]()
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        librariesTableView.dataSource = self
        librariesTableView.delegate = self
        librariesTableView.layer.cornerRadius = 5
        librariesTableView.separatorStyle = .None
        
        sendRequestToURLWithString(libraryUnitsURL)
    }
    
    // MARK: AFNetworking
    func sendRequestToURLWithString(URL: String) {
        manager.GET(URL, parameters: nil,
            success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let json = JSON(response)
                var libraryData = json["unit"]
                for index in 0..<libraryData.count {
                    let name = libraryData[index]["name"].string
                    let ID = libraryData[index]["id"].string
                    let code = libraryData[index]["code"].string
                    if let name = name, ID = ID, code = code {
                        var library = Library(name: name, ID: ID.toInt()!, code: code)
                        self.libraries.append(library)
                        self.librariesTableView.reloadData()
                    }
                }
                println("success")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            //TODO: implement failure condition
            println("failure: error \(error)")
        })
    }
    
    // MARK: Navigation 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLibraryDisplayViewController" {
            var destination = segue.destinationViewController as! LibraryDisplayViewController
            var indexPath = self.librariesTableView.indexPathForSelectedRow()
            destination.library = libraries[(indexPath?.row)!]
        }
    }
    
    @IBAction func unwindFromLibraryDisplayViewController(segue: UIStoryboardSegue, sender: UIButton?) {
        
    }
}

// MARK: UITableViewDataSource
extension LibraryListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("libraryListCell") as! LibraryListTableViewCell
        cell.libraryNameLabel.text = libraries[indexPath.row].name
        return cell
    }
}

// MARK: UITableViewDelegate
extension LibraryListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

