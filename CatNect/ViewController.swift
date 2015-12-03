//
//  ViewController.swift
//  CatNect
//
//  Created by Alex Nuccio on 9/28/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var Menu: Array<UIBarButtonItem> = []

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    var locationManager: CLLocationManager?
    
    var alreadySetupMap: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getPosts()
        getMyPosts()
        
        mapView?.delegate = self
        feedTableView?.delegate = self
        feedTableView?.dataSource = self
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.BlackTranslucent
        nav?.barTintColor = UIColor.redColor()
        nav?.tintColor = UIColor.whiteColor()
        
        
        for menu in self.Menu {
            menu.target = self.revealViewController()
            menu.action = Selector("revealToggle:")
        }
        self.automaticallyAdjustsScrollViewInsets = false;
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for menu in self.Menu {
            menu.target = self.revealViewController()
            menu.action = Selector("revealToggle:")
        }
        
        //are location services available on this device?
        if CLLocationManager.locationServicesEnabled() {
            //do we have authorization to find location?
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways :
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                createLocationManager(startImmediately: true)
            case .Denied:
                displayAlertWithTitle("Not determined", message: "Location services are not available")
            case .NotDetermined:
                //we do not know yet, have to ask
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                displayAlertWithTitle("Restriced", message: "Locatin services are not available")
            }
            
        } else {
            //location services are not available
            print("Location services are not enabled, please enable them")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMap(){
        //innitialize map and markers
        let latitude: Double = Double(variables.currentUser["latitude"]!)!
        let longitude: Double = Double(variables.currentUser["longitude"]!)!
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView?.setRegion(region, animated: true)
        mapView?.showsUserLocation = true
        placeMarkers()
        alreadySetupMap = true;
    }
    
    func placeMarkers() {
        //add markers on the map for every post
        for var i = 0; i < variables.postBody.count; i++ {
            let lat: Double = Double(variables.postLatitude[i])
            let long = Double(variables.postLongitude[i])
            let pinLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let pin = MKPointAnnotation()
            pin.coordinate = pinLocation
            pin.title = variables.postLocation[i]
            self.mapView?.addAnnotation(pin)
        }
    }
    
    func createLocationManager(startImmediately startImmediately: Bool) {
        locationManager = CLLocationManager()
        if let manager = locationManager {
            print("Successfully created the location manager: \(startImmediately)")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        //update currentUser variable to store new lat and long
        let latitude: String = "\(newLocation.coordinate.latitude)"
        let longitude: String = "\(newLocation.coordinate.longitude)"
        variables.currentUser["latitude"] = latitude
        variables.currentUser["longitude"] = longitude
        if(!alreadySetupMap) {
            print("lat: \(newLocation.coordinate.latitude)")
            print("long: \(newLocation.coordinate.longitude)")
            setupMap()
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeedTableViewCell = self.feedTableView?.dequeueReusableCellWithIdentifier("cell") as! FeedTableViewCell
        //error checking (if new post was added, indexPath will be out of range until posts are updated)
        if(indexPath.row >= variables.postBody.count) {
            return cell
        }
        cell.userField.text = variables.postUser[indexPath.row]
        cell.bodyField.text = variables.postBody[indexPath.row]
        cell.locationField.text = variables.postLocation[indexPath.row]
        //filter postDate to display meaningful string
        let str = variables.postDate[indexPath.row]
        let year:String = str.substringWithRange(Range<String.Index>(start: str.startIndex, end: str.startIndex.advancedBy(4)))
        let month:String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(5), end: str.startIndex.advancedBy(7)))
        let day: String = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(8), end: str.startIndex.advancedBy(10)))
        //set filtered string to dateField of cell
        cell.dateField.text = "\(month)-\(day)-\(year)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        variables.postToDisplay["username"] = variables.postUser[indexPath.row]
        variables.postToDisplay["body"] = variables.postBody[indexPath.row]
        variables.postToDisplay["title"] = variables.postTitle[indexPath.row]
        variables.postToDisplay["category"] = variables.postCategory[indexPath.row]
        variables.postToDisplay["location"] = variables.postLocation[indexPath.row]
        variables.postToDisplay["latitude"] = "\(variables.postLatitude[indexPath.row])"
        variables.postToDisplay["longitude"] = "\(variables.postLongitude[indexPath.row])"
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("displayPostSegue", sender: self)
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.postBody.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func getPosts() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/posts")!)
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
                    variables.postTitle = []
                    variables.postCategory = []
                    variables.postDate = []
                    variables.postLocation = []
                    variables.postLatitude = []
                    variables.postLongitude = []
                    for var i = 0; i < data.count; i++ {
                        //print(data[i]["body"] as! String)
                        variables.postBody.append(data[i]["body"] as! String)
                        variables.postUser.append(data[i]["username"] as! String)
                        variables.postTitle.append(data[i]["title"] as! String)
                        variables.postCategory.append(data[i]["category"] as! String)
                        variables.postDate.append(data[i]["date"] as! String)
                        variables.postLocation.append(data[i]["location"] as! String)
                        variables.postLatitude.append(data[i]["latitude"] as! Double)
                        variables.postLongitude.append(data[i]["longitude"] as! Double)
                    }
                    variables.postBody = variables.postBody.reverse()
                    variables.postUser = variables.postUser.reverse()
                    variables.postTitle = variables.postTitle.reverse()
                    variables.postCategory = variables.postCategory.reverse()
                    variables.postLocation = variables.postLocation.reverse()
                    variables.postDate = variables.postDate.reverse()
                    variables.postLatitude = variables.postLatitude.reverse()
                    variables.postLongitude = variables.postLongitude.reverse()
                }
                
            }
        })
        task.resume()
    }
    
    


    @IBAction func login(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/login")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let username = usernameField.text!
        let password = passwordField.text!
        let lat = variables.currentUser["latitude"]!
        let long = variables.currentUser["longitude"]!
        let string: NSString = "username=\(username)&password=\(password)&latitude=\(lat)&longitude=\(long)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    //login was successful, redirect to homepage
                    variables.currentUser["username"] = self.usernameField.text!
                    self.getUserInfo()
                    self.getMyPosts()
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
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/users")!)
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
                }
                
            }
        })
        task.resume()

    }
    
    func getMyPosts() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/myPosts")!)
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
                    variables.myPostBody.removeAll()
                    variables.myPostUser.removeAll()
                    variables.myPostDate.removeAll()
                    variables.myPostLocation.removeAll()
                    variables.myPostLatitude.removeAll()
                    variables.myPostLongitude.removeAll()
                    for var i = 0; i < data.count; i++ {
                        print(data[i]["body"] as! String)
                        variables.myPostBody.append(data[i]["body"] as! String)
                        variables.myPostUser.append(data[i]["username"] as! String)
                        variables.myPostDate.append(data[i]["date"] as! String)
                        variables.myPostLocation.append(data[i]["location"] as! String)
                        variables.myPostLatitude.append(data[i]["latitude"] as! Double)
                        variables.myPostLongitude.append(data[i]["longitude"] as! Double)
                    }
                    variables.myPostBody = variables.myPostBody.reverse()
                    variables.myPostUser = variables.myPostUser.reverse()
                    variables.myPostLocation = variables.myPostLocation.reverse()
                    variables.myPostDate = variables.myPostDate.reverse()
                    variables.myPostLatitude = variables.myPostLatitude.reverse()
                    variables.myPostLongitude = variables.myPostLongitude.reverse()
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
    
    
    @IBAction func logout(sender: UIButton) {
        variables.currentUser["username"] = ""
        variables.currentUser["phone"] = ""
        variables.currentUser["password"] = ""
        dispatch_async(dispatch_get_main_queue()){
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }
    }
    
    @IBAction func newPost(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("newPostSegue", sender: self)
        }
    }
    
    
    @IBAction func gotoRegister(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("registerSegue", sender: self)
        }
    }

}

