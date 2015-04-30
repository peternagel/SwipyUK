//
//  ButtonTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 17/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleBtn.layer.cornerRadius = 4.0
        titleBtn.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
