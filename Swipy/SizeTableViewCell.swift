//
//  SizeTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 31/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class SizeTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkmarkLbl: UILabel!
    var titleTxt: String!
    var amountTxt: String!
    var isAllSize = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        frameViw.layer.cornerRadius = 4.0
        frameViw.layer.masksToBounds = true
        frameViw.layer.borderWidth = 1.0
        frameViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let totalTxt = titleTxt + "  " + amountTxt as NSString
        var totalStr = NSMutableAttributedString(string: totalTxt as String)
        let titleRng = totalTxt.rangeOfString(titleTxt)
        var amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
        
        if selected {
            frameViw.layer.borderColor = UIColor.blackColor().CGColor
            if isAllSize {
                checkmarkLbl.alpha = 0.0
            } else {
                checkmarkLbl.alpha = 1.0
            }
            
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 14)!, range: titleRng)
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-BoldItalic", size: 14)!, range: amountRng)
        } else {
            frameViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
            checkmarkLbl.alpha = 0.0
            
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 14)!, range: titleRng)
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
        }
        
        titleLbl.attributedText = totalStr
    }
    
    func config(info: [String: AnyObject], isAll: Bool) {
        isAllSize = isAll
        if isAll {
            titleLbl.textAlignment = .Center
        } else {
            titleLbl.textAlignment = .Left
        }
        
        titleTxt = info["number"] as! String
        let amount = info["amount"] as! Int
        amountTxt = amount > 0 ? "(\(amount))" : ""
        
        if amount > 0 {
            self.userInteractionEnabled = true
            titleLbl.alpha = 1.0
        } else {
            self.userInteractionEnabled = false
            titleLbl.alpha = 0.5
        }
        
        let totalTxt = titleTxt + "  " + amountTxt as NSString
        var totalStr = NSMutableAttributedString(string: totalTxt as String)
        if !isAll {
            let amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
        }
        titleLbl.attributedText = totalStr
    }

}
