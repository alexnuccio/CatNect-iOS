//
//  FeedTableViewCell.swift
//  CatNect
//
//  Created by Alex Nuccio on 9/28/15.
//  Copyright © 2015 Alex Nuccio. All rights reserved.
//

import Foundation
import UIKit

class FeedTableViewCell: UITableViewCell {
    
    //add any components to be on table cell
    @IBOutlet weak var userField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var bodyField: UILabel!
    @IBOutlet weak var locationField: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}