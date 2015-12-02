//
//  DisplaySearchController.swift
//  CatNect
//
//  Created by Alex Nuccio on 11/23/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

class DisplaySearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView?.delegate = self
        searchTableView?.dataSource = self
        
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.searchPostBody.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell = self.searchTableView?.dequeueReusableCellWithIdentifier("cell") as! FeedTableViewCell
        //error checking (if new post was added, indexPath will be out of range until posts are updated)
        if(indexPath.row >= variables.searchPostBody.count) {
            return cell
        }
        cell.userField.text = variables.searchPostUser[indexPath.row]
        cell.bodyField.text = variables.searchPostBody[indexPath.row]
        cell.locationField.text = variables.searchPostLocation[indexPath.row]
        //filter postDate to display meaningful string
        let str = variables.searchPostDate[indexPath.row]
        let year:String = str.substringWithRange(Range<String.Index>(start: str.startIndex, end: str.startIndex.advancedBy(4)))
        let month:String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(5), end: str.startIndex.advancedBy(7)))
        let day: String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(8), end: str.startIndex.advancedBy(10)))
        //set filtered string to dateField of cell
        cell.dateField.text = "\(month)-\(day)-\(year)"
        return cell
    }
}