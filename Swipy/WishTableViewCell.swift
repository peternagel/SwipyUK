//
//  WishTableViewCell.swift
//  Swipy
//
//  Created by Niklas Olsson on 09/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class WishTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViw: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var merchantLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var shopBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.removeBtn.layer.cornerRadius = self.removeBtn.frame.size.width / 2.0
        self.removeBtn.layer.masksToBounds = true
        self.removeBtn.layer.borderWidth = 1.0
        
        self.shopBtn.layer.cornerRadius = 2.0
        self.shopBtn.layer.masksToBounds = true
        self.shopBtn.layer.borderWidth = 1.0
        self.shopBtn.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configWithGood(item: SWGood) {
        let image_url = NSURL(string: item.imageLink)
        self.imageViw.sd_setImageWithPreviousCachedImageWithURL(image_url, andPlaceholderImage: nil, options: .RetryFailed, progress: nil, completed: nil)
        
        // for other images
        let dummyImageViw = UIImageView()
        for imageItem in item.images {
            let itemUrl = NSURL(string: imageItem)
            dummyImageViw.sd_setImageWithURL(itemUrl)
        }
        
        self.titleLbl.text = item.title
        
        var priceTxt: NSString
        let oldPrice = Utils.sharedInstance.currencyStringFor(item.oldPrice)
        let price = Utils.sharedInstance.currencyStringFor(item.price)
        if item.oldPrice == item.price {
            priceTxt = price
        } else {
            priceTxt = oldPrice + "  " + price
        }
        var attributedStr = NSMutableAttributedString(string: priceTxt as String)
        let oldPriceRng = priceTxt.rangeOfString(oldPrice)
        if item.oldPrice != item.price {
            attributedStr.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: oldPriceRng)
            attributedStr.addAttribute(NSStrikethroughColorAttributeName, value: UIColor.blackColor(), range: oldPriceRng)
        }
        self.priceLbl.attributedText = attributedStr
        
        var detailTxt = item.merchant as NSString
        var discountTxt = ""
        if item.discountPercent > 0 {
            discountTxt = "- \(item.discountPercent) %"
            detailTxt = detailTxt.stringByAppendingFormat("     %@", discountTxt)
        }
        var attributedDetail = NSMutableAttributedString(string: detailTxt as String)
        if item.discountPercent > 0 {
            let discountRng = detailTxt.rangeOfString(discountTxt)
            attributedDetail.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-LightItalic", size: 12)!, range: discountRng)
            var redColor = UIColor(red: 240/255.0, green: 119/255.0, blue: 139/255.0, alpha: 1.0)
            attributedDetail.addAttribute(NSForegroundColorAttributeName, value: redColor, range: discountRng)
        }
        self.merchantLbl.attributedText = attributedDetail
    }

}
