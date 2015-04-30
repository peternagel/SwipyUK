//
//  LinkTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 17/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class LinkTableViewCell: UITableViewCell {

    @IBOutlet weak var iconLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconLbl.font = UIFont.fontAwesomeOfSize(16)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
