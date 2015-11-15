//
//  MyPostController.swift
//  CatNect
//
//  Created by Alex Nuccio on 11/1/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation
import UIKit

class MyPostController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu.target = self.revealViewController()
        menu.action = Selector("revealToggle:")
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.barTintColor = UIColor.redColor()
        nav?.tintColor = UIColor.whiteColor()
        
        myTableView?.delegate = self
        myTableView?.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell = self.myTableView?.dequeueReusableCellWithIdentifier("cell2") as! FeedTableViewCell
        //error checking (if new post was added, indexPath will be out of range until posts are updated)
        print(variables.myPostBody.count)
        if(indexPath.row > variables.myPostBody.count) {
            return cell
        }
        cell.userField.text = variables.myPostUser[indexPath.row]
        cell.bodyField.text = variables.myPostBody[indexPath.row]
        cell.locationField.text = variables.myPostLocation[indexPath.row]
        //filter postDate to display meaningful string
        let str = variables.myPostDate[indexPath.row]
        let year:String = str.substringWithRange(Range<String.Index>(start: str.startIndex, end: str.startIndex.advancedBy(4)))
        let month:String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(5), end: str.startIndex.advancedBy(7)))
        let day: String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(8), end: str.startIndex.advancedBy(10)))
        //set filtered string to dateField of cell
        cell.dateField.text = "\(month)-\(day)-\(year)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.myPostBody.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
        
}
