//
//  NormalTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 17/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class NormalTableViewCell: UITableViewCell {

    @IBOutlet weak var titleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleBtn.layer.cornerRadius = 4.0
        titleBtn.layer.masksToBounds = true
        titleBtn.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).CGColor
        titleBtn.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
