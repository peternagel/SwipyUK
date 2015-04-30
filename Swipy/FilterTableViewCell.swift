//
//  FilterTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 13/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var frameViw: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.frameViw.layer.cornerRadius = 4.0
        self.frameViw.layer.borderWidth = 1.0
        self.frameViw.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(filter: [String: AnyObject], index: Int) {
        titleLbl.textColor = UIColor.blackColor()
        
        var titleTxt: String!
        switch index {
        case 0:
            let mainCategory = filter["mainCategory"] as! [String: AnyObject]?
            if mainCategory == nil {
                titleTxt = NSLocalizedString("All Categories", comment: "")
            } else {
                titleTxt = mainCategory?["title"] as! String
                let subCategories = filter["subCategories"] as! [[String: AnyObject]]?
                if subCategories != nil {
                    for var i = 0; i < subCategories?.count; i++ {
                        let subItemTitle = subCategories?[i]["title"] as! String
                        if i == 0 {
                            titleTxt = titleTxt + " > " + subItemTitle
                        } else {
                            titleTxt = titleTxt + ", " + subItemTitle
                        }
                    }
                }
            }
            
        case 1:
            let sizes = filter["sizes"] as! [[String: AnyObject]]?
            if sizes == nil {
                titleTxt = NSLocalizedString("All Sizes", comment: "")
            } else {
                titleTxt = "Größe"
                for var i = 0; i < sizes?.count; i++ {
                    let sizeName = sizes?[i]["number"] as! String
                    if i == 0 {
                        titleTxt = titleTxt + ": " + sizeName
                    } else {
                        titleTxt = titleTxt + ", " + sizeName
                    }
                }
            }
            
        case 2:
            let rebate = filter["rebate"] as! [String: AnyObject]?
            if rebate == nil {
                titleTxt = NSLocalizedString("All Sales", comment: "")
            } else {
                let idVal = rebate?["id"] as! Int
                if idVal == 0 {
                    titleTxt = "Rabatt: Alle Sale Angebote zeigen"
                } else {
                    titleTxt = "Rabatt: Mindestens " + "\(idVal)" + "% reduziert"
                }
                titleLbl.textColor = UIColor(red: 232/255.0, green: 64/255.0, blue: 89/255.0, alpha: 1.0)
            }
            
        case 3:
            let minPrice = filter["min"] as! Int
            let maxPrice = filter["max"] as! Int
            if minPrice == 0 && maxPrice == 0 {
                titleTxt = NSLocalizedString("All Prices", comment: "")
            } else {
                if minPrice == 0 {
                    titleTxt = "Preis: Unter " + Utils.sharedInstance.currencyStringFor(maxPrice)
                } else {
                    if maxPrice == 0 {
                        titleTxt = "Preis: Über " + Utils.sharedInstance.currencyStringFor(minPrice)
                    } else {
                        titleTxt = "Preis: Zwischen " + Utils.sharedInstance.currencyStringFor(minPrice) + " und " + Utils.sharedInstance.currencyStringFor(maxPrice)
                    }
                }
            }
            
        case 4:
            let colors = filter["colors"] as! [[String: AnyObject]]?
            if colors == nil {
                titleTxt = NSLocalizedString("All Colors", comment: "")
            } else {
                titleTxt = "Farben"
                for var i = 0; i < colors?.count; i++ {
                    let colorName = colors?[i]["name"] as! String
                    if i == 0 {
                        titleTxt = titleTxt + ": " + colorName
                    } else {
                        titleTxt = titleTxt + ", " + colorName
                    }
                }
            }
            
        case 5:
            if let brands = filter["brands"] as! [[String: AnyObject]]? {
                titleTxt = "Marken"
                for var i = 0; i < brands.count; i++ {
                    let brandName = brands[i]["name"] as! String
                    if i == 0 {
                        titleTxt = titleTxt + ": " + brandName
                    } else {
                        titleTxt = titleTxt + ", " + brandName
                    }
                }
            } else {
                titleTxt = NSLocalizedString("All Brands", comment: "")
            }
            
        case 6:
            let shops = filter["shops"] as! [[String: AnyObject]]?
            if shops == nil {
                titleTxt = NSLocalizedString("All Shops", comment: "")
            } else {
                titleTxt = "Shops"
                for var i = 0; i < shops?.count; i++ {
                    let shopName = shops?[i]["name"] as! String
                    if i == 0 {
                        titleTxt = titleTxt + ": " + shopName
                    } else {
                        titleTxt = titleTxt + ", " + shopName
                    }
                }
            }
            
        default:
            titleTxt = " "
        }
        
        titleLbl.text = titleTxt
    }

}
