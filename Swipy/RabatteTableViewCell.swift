//
//  RabatteTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class RabatteTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkmarkLbl: UILabel!
    var titleTxt: String!
    var amountTxt: String!
    var isAllRabatte = false
    
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
        let amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
        
        if selected {
            frameViw.layer.borderColor = UIColor.blackColor().CGColor
            if isAllRabatte {
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
        isAllRabatte = isAll
        if isAll {
            titleLbl.textAlignment = .Center
            titleLbl.textColor = UIColor.blackColor()
        } else {
            titleLbl.textAlignment = .Left
            titleLbl.textColor = UIColor(red: 232/255.0, green: 64/255.0, blue: 89/255.0, alpha: 1.0)
        }
        
        let idVal = info["id"] as! Int
        if idVal == -1 {
            titleTxt = NSLocalizedString("All Sales", comment: "")
        } else if idVal == 0 {
            titleTxt = "Alle Sale Angebote zeigen"
        } else {
            titleTxt = "Mindestens " + "\(idVal)" + "% reduziert"
        }
        let amount = info["amount"] as! Int
        amountTxt = "(\(amount))"
        let totalTxt = titleTxt + "  " + amountTxt as NSString
        
        if amount > 0 {
            self.userInteractionEnabled = true
            titleLbl.alpha = 1.0
        } else {
            self.userInteractionEnabled = false
            titleLbl.alpha = 0.5
        }
        
        var totalStr = NSMutableAttributedString(string: totalTxt as String)
        let amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
        totalStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
        titleLbl.attributedText = totalStr
    }

}
