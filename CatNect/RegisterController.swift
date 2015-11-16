//
//  RegisterController.swift
//  CatNect
//
//  Created by Alex Nuccio on 10/8/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

class RegisterController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypePasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func register(sender: UIButton) {
        if usernameField.text == "" || phoneField.text == "" || passwordField == "" || retypePasswordField.text == "" {
            //didnt completely fill out form
            dispatch_async(dispatch_get_main_queue()) {
                self.displayAlertWithTitle("Missing Fields", message: "Please fill out all required fields.")
            }
            return
        }
        if passwordField.text! != retypePasswordField.text! {
            //passwords dont match
            dispatch_async(dispatch_get_main_queue()) {
                self.displayAlertWithTitle("Password Error", message: "Passwords must match.")
            }
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://catnect.herokuapp.com/register")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let username = usernameField.text!
        let phone = phoneField.text!
        let password = passwordField.text!
        let string: NSString = "username=\(username)&password=\(password)&phone=\(phone)"
        let body = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.HTTPBody = body
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
                if(httpResponse.statusCode == 200) {
                    dispatch_async(dispatch_get_main_queue()) {
                        variables.currentUser["username"] = username
                        variables.currentUser["phone"] = phone
                        self.performSegueWithIdentifier("registerSuccessSegue", sender: self)
                    }
                    
                    
                } else {
                    self.displayAlertWithTitle("Register Error", message: "Something went wrong. Please try again.")
                    return
                }
                
            }
        })
        task.resume()
    }
    
    @IBAction func goBack(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("backToLoginSegue", sender: self)
        }
    }
    
    func displayAlertWithTitle(tite: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
}