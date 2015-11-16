//
//  NewPostController.swift
//  CatNect
//
//  Created by Alex Nuccio on 10/6/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class NewPostController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var categoryArray: [String] = ["Sports", "Clubs", "Social Gathering", "Food", "Academic", "Music", "Shows", "Exhibition", "Greek", "Other"]
    
    var locationManager: CLLocationManager?
    
    var postLatitude: Double = 0, postLongitude: Double = 0
    
    @IBAction func submitClicked(sender: UIButton) {
        //error checking
        if locationText.text == nil || descriptionText.text == nil {
            self.displayAlertWithTitle("Must fill out all required forms", message: "Please fill out all the required fields.")
            return
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/newPost")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var date: String = "\((datePicker.date))"
        date = date.substringWithRange(Range<String.Index>(start: date.startIndex, end: date.startIndex.advancedBy(19)))
        let location = locationText.text!
        //let title = titleText?.text
        let bodyText = descriptionText.text!
        let username = variables.currentUser["username"]!
        let title = titleText.text!
        let row = categoryPicker.selectedRowInComponent(0)
        let category = categoryArray[row]
        
        var lat: Double, long: Double
        if postLatitude == 0 {
            //user did not specify location
            lat = 50
            long = 50
        } else {
            lat = postLatitude
            long = postLongitude
        }
        //TODO:add title to post
        let string: NSString = "username=\(username)&title=\(title)&category=\(category)&date=\(date)&location=\(location)&latitude=\(lat)&longitude=\(long)&body=\(bodyText)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                
                if httpResponse.statusCode == 200 {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Successfully Posted", message: "Successfully created a new event post")
                        self.performSegueWithIdentifier("postReturnSegue", sender: self)
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Cancelled Post", message: "Cancelled new post")
                        return
                    }
                }
                
            }
            
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        categoryPicker?.delegate = self
        categoryPicker?.dataSource = self
        setupMap()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressGesture.minimumPressDuration = 2;
        mapView.addGestureRecognizer(longPressGesture)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addPin(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            let touchPoint = gesture.locationInView(self.mapView)
            let newCoordinates = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            print("COORDINATED: \(newCoordinates.latitude) & \(newCoordinates.longitude)")
            postLatitude = newCoordinates.latitude as Double
            postLongitude = newCoordinates.longitude as Double
            
            
            self.mapView!.addAnnotation(annotation)
            
            
        }
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
    
    func setupMap(){
        //innitialize map and markers
        let latitude: Double = Double(variables.currentUser["latitude"]!)!
        let longitude: Double = Double(variables.currentUser["longitude"]!)!
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView?.setRegion(region, animated: true)
        mapView?.showsUserLocation = true
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func displayAlertWithTitle(tite: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }

}