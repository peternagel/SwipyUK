//
//  SubCategoryTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class SubCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkmarkLbl: UILabel!
    var titleTxt: String!
    var amountTxt: String!
    var isAllCategory = false
    
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
        var totalTxt: NSString
        if isAllCategory {
            totalTxt = titleTxt
        } else {
            totalTxt = titleTxt + "  " + amountTxt
        }
        var totalStr = NSMutableAttributedString(string: totalTxt as String)
        let titleRng = totalTxt.rangeOfString(titleTxt)
        var amountRng: NSRange!
        if !isAllCategory {
            amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
        }
        
        if selected {
            frameViw.layer.borderColor = UIColor.blackColor().CGColor
            if isAllCategory {
                checkmarkLbl.alpha = 0.0
            } else {
                checkmarkLbl.alpha = 1.0
            }
            
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 14)!, range: titleRng)
            if !isAllCategory {
                totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-BoldItalic", size: 14)!, range: amountRng)
            }
        } else {
            frameViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
            checkmarkLbl.alpha = 0.0
            
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 14)!, range: titleRng)
            if !isAllCategory {
                totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
            }
        }
        
        titleLbl.attributedText = totalStr
    }
    
    func config(info: [String: AnyObject], isAll: Bool) {
        isAllCategory = isAll
        if isAll {
            titleLbl.textAlignment = .Center
        } else {
            titleLbl.textAlignment = .Left
        }
        
        titleTxt = info["title"] as! String
        let amount = info["amount"] as! Int!
        if amount != nil && amount > 0 {
            amountTxt = "(\(amount))"
        } else {
            amountTxt = ""
        }
        
        if amount > 0 {
            self.userInteractionEnabled = true
            titleLbl.alpha = 1.0
        } else {
            self.userInteractionEnabled = false
            titleLbl.alpha = 0.5
        }
        
        var totalTxt: NSString
        if isAll {
            totalTxt = titleTxt
        } else {
            totalTxt = titleTxt + "  " + amountTxt
        }
        
        var totalStr = NSMutableAttributedString(string: totalTxt as String)
        if !isAll {
            let amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
            totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
        }
        titleLbl.attributedText = totalStr
    }

}
