//
//  profileController.swift
//  CatNect
//
//  Created by Weicheng on 9/30/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation

class profileController: ViewController {
    
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var passwordLable: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateLabels()
    }
    
    func populateLabels() {
        dispatch_async(dispatch_get_main_queue()) {
            self.usernameLabel.text = variables.currentUser["username"]!
            self.phoneLabel.text = variables.currentUser["phone"]!
        }

    }
}