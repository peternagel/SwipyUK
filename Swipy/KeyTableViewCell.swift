//
//  KeyTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 16/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class KeyTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var keyLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        frameViw.layer.cornerRadius = 4.0
        frameViw.layer.masksToBounds = true
        
        deleteBtn.layer.cornerRadius = deleteBtn.frame.size.width / 2.0
        deleteBtn.layer.masksToBounds = true
        deleteBtn.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
