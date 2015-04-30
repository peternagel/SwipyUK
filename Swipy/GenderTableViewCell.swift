//
//  GenderTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 16/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class GenderTableViewCell: UITableViewCell {

    @IBOutlet weak var genderSelector: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
