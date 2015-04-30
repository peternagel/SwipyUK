//
//  KeyInputTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 16/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class KeyInputTableViewCell: UITableViewCell {

    @IBOutlet weak var keyFld: UITextField!
    @IBOutlet weak var marginToRight: NSLayoutConstraint!
    @IBOutlet weak var selectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectBtn.layer.cornerRadius = 4.0
        selectBtn.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showSelectButton(visible: Bool) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            if visible {
                self.selectBtn.alpha = 1.0
                self.marginToRight.constant = 114.0
            } else {
                self.selectBtn.alpha = 0.0
                self.marginToRight.constant = 10.0
            }
        }) { (isFinished) -> Void in
            if isFinished {
                self.setNeedsLayout()
            }
        }
    }

}
