//
//  NewPostController.swift
//  CatNect
//
//  Created by Alex Nuccio on 10/6/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

class NewPostController: UIViewController {
    
    @IBOutlet weak var titleText: UITextField!
    
    
    @IBOutlet weak var locationText: UITextField!
    
    
    @IBOutlet weak var descriptionText: UITextField!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func submitClicked(sender: UIButton) {
        //error checking
        if locationText.text == nil || descriptionText.text == nil {
            self.displayAlertWithTitle("Must fill out all required forms", message: "Please fill out all the required fields.")
            return
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/newPost")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var date: String = "\((datePicker.date))"
        date = date.substringWithRange(Range<String.Index>(start: date.startIndex, end: date.startIndex.advancedBy(19)))
        let location = locationText.text!
        //let title = titleText?.text
        let bodyText = descriptionText.text!
        let username = variables.currentUser["username"]!
        //TODO:add title to post
        let string: NSString = "username=\(username)&date=\(date)&location=\(location)&body=\(bodyText)"
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