//
//  PriceTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class PriceTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkmarkLbl: UILabel!
    var isAllPrice = false
    
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
        /*if selected {
            frameViw.layer.borderColor = UIColor.blackColor().CGColor
            if isAllPrice {
                checkmarkLbl.alpha = 0.0
            } else {
                checkmarkLbl.alpha = 1.0
            }
            titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 10)!
        } else {
            frameViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
            checkmarkLbl.alpha = 0.0
            titleLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 10)!
        }*/
    }
    
    func config(price: [String: AnyObject], isAll: Bool) {
        isAllPrice = isAll
        if isAll {
            titleLbl.textAlignment = .Center
        } else {
            titleLbl.textAlignment = .Left
        }
        
        var titleTxt = ""
        if isAll {
            titleTxt = NSLocalizedString("All Prices", comment: "")
        } else {
            if let minVal = price["min"] as? Int {
                if minVal > 0 {
                    titleTxt = NSLocalizedString("Over", comment: "") + " " + Utils.sharedInstance.currencyStringFor(minVal)
                } else if let maxVal = price["max"] as? Int {
                    if maxVal > 0 {
                        titleTxt = NSLocalizedString("Under", comment: "") + " " + Utils.sharedInstance.currencyStringFor(maxVal)
                    }
                }
            }
        }
        
        let amount = price["amount"] as! Int
        let amountTxt = "(\(amount))"
        
        if amount > 0 {
            self.userInteractionEnabled = true
            titleLbl.alpha = 1.0
        } else {
            self.userInteractionEnabled = false
            titleLbl.alpha = 0.5
        }
        
        let totalTxt = titleTxt + "  " + amountTxt
        var totalStr = NSMutableAttributedString(string: totalTxt)
        let amountRng = (totalTxt as NSString).rangeOfString(amountTxt, options: .BackwardsSearch)
        totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
        titleLbl.attributedText = totalStr
    }

}
