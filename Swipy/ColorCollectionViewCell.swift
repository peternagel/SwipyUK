//
//  ColorCollectionViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorViw.layer.cornerRadius = colorViw.frame.width / 2.0
        colorViw.layer.masksToBounds = true
        colorViw.layer.borderWidth = 1.0
        colorViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                colorViw.layer.borderColor = UIColor.blackColor().CGColor
                titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 11)!
                amountLbl.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 11)!
            } else {
                colorViw.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
                titleLbl.font = UIFont(name: "HelveticaNeue-Thin", size: 11)!
                amountLbl.font = UIFont(name: "HelveticaNeue-ThinItalic", size: 11)!
            }
        }
    }
    
    func config(info: [String: AnyObject]) {
        titleLbl.text = info["name"] as? String
        let amount = info["amount"] as! Int
        amountLbl.text = "(\(amount))"
        
        if amount > 0 {
            self.userInteractionEnabled = true
            titleLbl.alpha = 1.0
            amountLbl.alpha = 1.0
        } else {
            self.userInteractionEnabled = false
            titleLbl.alpha = 0.5
            amountLbl.alpha = 0.5
        }
        
        let color = info["hexValue"] as! String
        colorViw.backgroundColor = UIColor(rgba: "#"+color)
    }
    
}
