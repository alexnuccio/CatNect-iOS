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
    static var postTitle = [String]()
    static var postCategory = [String]()
    static var postDate = [String]()
    static var postLocation = [String]()
    static var postLatitude = [Double]()
    static var postLongitude = [Double]()
    
    static var myPostBody = [String]()
    static var myPostUser = [String]()
    static var myPostDate = [String]()
    static var myPostLocation = [String]()
    static var myPostLatitude = [Double]()
    static var myPostLongitude = [Double]()
    
    static var searchPostBody = [String]()
    static var searchPostUser = [String]()
    static var searchPostDate = [String]()
    static var searchPostLocation = [String]()
    static var searchPostLatitude = [Double]()
    static var searchPostLongitude = [Double]()
    
    static var postToDisplay: [ String: String ] = [
        "username": "",
        "body": "",
        "title": "",
        "category": "",
        "location": "",
        "latitude": "",
        "longitude": ""
    ]
    
}