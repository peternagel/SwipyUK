//
//  SpecialTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 13/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class SpecialTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.frameViw.layer.cornerRadius = 4.0
        self.frameViw.layer.borderWidth = 2.0
        self.frameViw.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(specialInfo: [String: AnyObject], counts: [[String: String]]!) {
        titleLbl.text = specialInfo["title"] as? String
    }

}
