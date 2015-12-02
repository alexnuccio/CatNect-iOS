//
//  profileController.swift
//  CatNect
//
//  Created by Weicheng on 9/30/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation
import UIKit

class profileController: ViewController {
    
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateLabels()
    }
    
    func populateLabels() {
        dispatch_async(dispatch_get_main_queue()) {
            self.usernameLabel.text = variables.currentUser["username"]!
            self.phoneLabel.text = variables.currentUser["phone"]!
            self.passwordLabel.text = variables.currentUser["password"]!
        }

    }
    
    @IBAction func updateInformation(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/updateInfo")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let username = usernameLabel.text!
        let oldUsername = variables.currentUser["username"]!
        let password = passwordLabel.text!
        let phone = phoneLabel.text!
        let string: NSString = "newUsername=\(username)&oldUsername=\(oldUsername)&password=\(password)&phone=\(phone)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    //login was successful, redirect to homepage
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Update Successful", message: "Successfully updated user information.")
                        variables.currentUser["username"] = username
                        variables.currentUser["password"] = password
                        variables.currentUser["phone"] = phone
                        return
                    }
                } else {
                    //invalid password
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Update Unsuccessful", message: "Update failed.")
                        return
                    }
                }
            }
        })
        task.resume()
    }
    
    override func displayAlertWithTitle(tite: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
}