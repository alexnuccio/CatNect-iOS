//
//  DisplayPostController.swift
//  CatNect
//
//  Created by Alex Nuccio on 10/6/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation
import MapKit

class DisplayPostController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventBody: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        setupMap()
        
        //setup labels
        let user: String = variables.postToDisplay["username"]!
        let location: String = variables.postToDisplay["location"]!
        let body: String = variables.postToDisplay["body"]!
        eventTitle?.text = "\(user)'s Event"
        eventLocation?.text = "\(location)"
        eventBody?.text = "\(body)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupMap(){
        //innitialize map and markers
        let latitude: Double = Double(variables.postToDisplay["latitude"]!)!
        let longitude: Double = Double(variables.postToDisplay["longitude"]!)!
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView?.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let pin = MKPointAnnotation()
        pin.coordinate = pinLocation
        pin.title = variables.postToDisplay["location"]
        self.mapView?.addAnnotation(pin)
    }
}