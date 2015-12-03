//
//  SearchController.swift
//  CatNect
//
//  Created by Alex Nuccio on 11/19/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

class SearchController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var milesField: UITextField!
    
    var categoryArray: [String] = ["Sports", "Clubs", "Social Gathering", "Food", "Academic", "Music", "Shows", "Exhibition", "Greek", "Other"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup scroll view & nav bar
        self.automaticallyAdjustsScrollViewInsets = false;
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.barTintColor = UIColor.redColor()
        nav?.tintColor = UIColor.whiteColor()
        
        //setup menu button
        menu.target = self.revealViewController()
        menu.action = Selector("revealToggle:")
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row]
    }
    
    @IBAction func searchByCategory(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/passCategoryToServer")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let row = categoryPicker.selectedRowInComponent(0)
        let category = categoryArray[row]
        print("searching for category \(category)")
        let string: NSString = "category=\(category)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    //success
                    
                    //now process get request to get selected posts
                    self.getCategorySearchResults()
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.performSegueWithIdentifier("displayResults", sender: self)
                    }
                } else {
                    //fail - show message
                    dispatch_async(dispatch_get_main_queue()){
                        self.displayAlertWithTitle("Failed search", message: "Failed to communicate with the server")
                    }
                    return
                }
            }
        })
        task.resume()
        
        
        
    }

    
    @IBAction func searchByDistance(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/passDistanceToServer")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let distance = milesField.text!
        let string: NSString = "distance=\(distance)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    //success
                    
                    self.getDistanceSearchResults()
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.performSegueWithIdentifier("displayResults", sender: self)
                    }
                } else {
                    //fail - show message
                    dispatch_async(dispatch_get_main_queue()){
                        self.displayAlertWithTitle("Failed search", message: "Failed to communicate with the server")
                    }
                    return
                }
            }
        })
        task.resume()
        
        

        
    }
    
    func getDistanceSearchResults() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/getDistanceResults")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if(error != nil) {
                print(error)
            } else {
                let jsonData: NSArray?
                do{
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSArray
                } catch _ {
                    jsonData = nil
                }
                if let data = jsonData {
                    //data != nil
                    variables.searchPostBody.removeAll()
                    variables.searchPostUser.removeAll()
                    variables.searchPostDate.removeAll()
                    variables.searchPostLocation.removeAll()
                    variables.searchPostLatitude.removeAll()
                    variables.searchPostLongitude.removeAll()
                    
                    for var i = 0; i < data.count; i++ {
                        print("data:")
                        print(data[i]["body"] as! String)
                        variables.searchPostBody.append(data[i]["body"] as! String)
                        variables.searchPostUser.append(data[i]["username"] as! String)
                        variables.searchPostDate.append(data[i]["date"] as! String)
                        variables.searchPostLocation.append(data[i]["location"] as! String)
                        variables.searchPostLatitude.append(data[i]["latitude"] as! Double)
                        variables.searchPostLongitude.append(data[i]["longitude"] as! Double)
                    }
                    variables.searchPostBody = variables.searchPostBody.reverse()
                    variables.searchPostUser = variables.searchPostUser.reverse()
                    variables.searchPostLocation = variables.searchPostLocation.reverse()
                    variables.searchPostDate = variables.searchPostDate.reverse()
                    variables.searchPostLatitude = variables.searchPostLatitude.reverse()
                    variables.searchPostLongitude = variables.searchPostLongitude.reverse()
                }
                
            }
        })
        task.resume()
        
    }
    
    
    func getCategorySearchResults() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/getCategoryResults")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if(error != nil) {
                print(error)
            } else {
                let jsonData: NSArray?
                do{
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSArray
                } catch _ {
                    jsonData = nil
                }
                if let data = jsonData {
                    //data != nil
                    variables.searchPostBody.removeAll()
                    variables.searchPostUser.removeAll()
                    variables.searchPostDate.removeAll()
                    variables.searchPostLocation.removeAll()
                    variables.searchPostLatitude.removeAll()
                    variables.searchPostLongitude.removeAll()
                    
                    for var i = 0; i < data.count; i++ {
                        print(data[i]["body"] as! String)
                        variables.searchPostBody.append(data[i]["body"] as! String)
                        variables.searchPostUser.append(data[i]["username"] as! String)
                        variables.searchPostDate.append(data[i]["date"] as! String)
                        variables.searchPostLocation.append(data[i]["location"] as! String)
                        variables.searchPostLatitude.append(data[i]["latitude"] as! Double)
                        variables.searchPostLongitude.append(data[i]["longitude"] as! Double)
                    }
                    variables.searchPostBody = variables.searchPostBody.reverse()
                    variables.searchPostUser = variables.searchPostUser.reverse()
                    variables.searchPostLocation = variables.searchPostLocation.reverse()
                    variables.searchPostDate = variables.searchPostDate.reverse()
                    variables.searchPostLatitude = variables.searchPostLatitude.reverse()
                    variables.searchPostLongitude = variables.searchPostLongitude.reverse()
                }
                
            }
        })
        task.resume()

    }
    
    func displayAlertWithTitle(tite: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
}