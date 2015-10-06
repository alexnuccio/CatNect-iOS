//
//  MyVariables.swift
//  CatNect
//
//  Created by Alex Nuccio on 9/28/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

struct variables {
    
    static var currentUser: [ String: String ] = [
        "username": "",
        "password": "",
        "phone": "",
        "latitude": "",
        "longitude": ""
    ]
    
    static var postBody = [String]()
    static var postUser = [String]()
    static var postDate = [String]()
    static var postLocation = [String]()
    static var postLatitude = [Double]()
    static var postLongitude = [Double]()
    
    static var postToDisplay: [ String: String ] = [
        "username": "",
        "body": "",
        "location": "",
        "latitude": "",
        "longitude": ""
    ]
    
}