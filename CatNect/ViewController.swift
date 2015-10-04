//
//  ViewController.swift
//  CatNect
//
//  Created by Alex Nuccio on 9/28/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet var Menu: Array<UIBarButtonItem> = []

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getPosts()
        
        feedTableView?.delegate = self
        feedTableView?.dataSource = self
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.barTintColor = UIColor.redColor()
        
        
        for menu in self.Menu {
            menu.target = self.revealViewController()
            menu.action = Selector("revealToggle:")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell = self.feedTableView?.dequeueReusableCellWithIdentifier("cell") as! FeedTableViewCell
        cell.userField.text = variables.postUser[indexPath.row]
        cell.bodyField.text = variables.postBody[indexPath.row]
        cell.dateField.text = variables.postDate[indexPath.row]
        cell.locationField.text = variables.postLocation[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.postBody.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func getPosts() {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/posts")!)
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
                    variables.postBody = []
                    variables.postUser = []
                    variables.postDate = []
                    variables.postLocation = []
                    for var i = 0; i < data.count; i++ {
                        print(data[i]["body"] as! String)
                        variables.postBody.append(data[i]["body"] as! String)
                        variables.postUser.append(data[i]["username"] as! String)
                        variables.postDate.append(data[i]["date"] as! String)
                        variables.postLocation.append(data[i]["location"] as! String)
                    }
                }
                
            }
        })
        task.resume()
    }

    @IBAction func login(sender: UIButton) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/login")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let username = usernameField.text!
        let password = passwordField.text!
        let string: NSString = "username=\(username)&password=\(password)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    //login was successful, redirect to homepage
                    variables.currentUser["username"] = self.usernameField.text!
                    self.getUserInfo()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("loginSegue", sender: self)
                    }
                } else if(httpResponse.statusCode == 300) {
                    //username does not exist, try again
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("User Does Not Exist Error", message: "User not found. Try again.")
                        self.usernameField.text = ""
                        self.passwordField.text = ""
                    }
                } else {
                    //invalid password
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Invalid Password Error", message: "Invalid password. Try again.")
                        self.usernameField.text = ""
                        self.passwordField.text = ""
                    }
                }
            }
        })
        task.resume()

    }
    
    func getUserInfo() {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/users")!)
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
                    for var i = 0; i < data.count; i++ {
                        if (data[i]["username"] as! String) == variables.currentUser["username"] {
                            variables.currentUser["password"] = (data[i]["password"] as! String)
                            variables.currentUser["phone"] = (data[i]["phone"] as! String)
                        }
                    }
                    print(variables.currentUser["phone"]!)
                    print(variables.currentUser["username"]!)

                    
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

