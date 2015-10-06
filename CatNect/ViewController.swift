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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
                    variables.postLatitude = []
                    variables.postLongitude = []
                    for var i = 0; i < data.count; i++ {
                        print(data[i]["body"] as! String)
                        variables.postBody.append(data[i]["body"] as! String)
                        variables.postUser.append(data[i]["username"] as! String)
                        variables.postDate.append(data[i]["date"] as! String)
                        variables.postLocation.append(data[i]["location"] as! String)
                        variables.postLatitude.append(data[i]["latitude"] as! Double)
                        variables.postLongitude.append(data[i]["longitude"] as! Double)
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

