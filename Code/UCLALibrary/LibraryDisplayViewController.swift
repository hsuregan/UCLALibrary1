//
//  LibraryDetailViewController.swift
//  UCLALibrary
//
//  Created by Chris Orcutt on 7/16/15.
//  Copyright (c) 2015 Chris Orcutt. All rights reserved.
//

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
    
    func setupHorizontalScrollView() {
        let count = library.operatingHours?.count ?? 0
        
        for index in 0..<count {
            var view = LibraryHoursView()
            view.frame.origin = CGPoint(x: CGFloat(index) * view.frame.width, y: 0)
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
