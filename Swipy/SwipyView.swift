//
//  SwipyView.swift
//  Swipy
//
//  Created by Niklas Olsson on 25/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class SwipyView: MDCSwipeToChooseView {

    var item: SWItem!
    var likesView: UIView!
    var likesCount: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, goodInfo: SWItem!, options: MDCSwipeToChooseViewOptions!) {
        super.init(frame: frame, options: options)
        
        item = goodInfo
        
        self.backgroundColor = UIColor.whiteColor()
        self.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.layer.borderWidth = 0.0
        
        setupImageView()
        if let good = item as? SWGood {
            setupLikes(good)
            setupDiscount(good)
            setupDetailInfo(good)
        }
    }
    
    func setupImageView() {
        if item.imageLink.isEmpty {
            return
        }
        
        self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)
        imageView.contentMode = .ScaleAspectFit
        imageView.autoresizingMask = self.autoresizingMask
        let image_url = NSURL(string: item.imageLink)
        // imageView.setImageWithURL(image_url)
        imageView.sd_setImageWithURL(image_url, placeholderImage: nil, options: .CacheMemoryOnly)
    }
    
    func setupLikes(good: SWGood) {
        if good.likes <= 0 {
            return
        }
        
        self.likedView = UIView(frame: CGRectMake(0, 0, 80, 22))
        self.likedView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.likedView)
        
        var likeImage = UIImageView(frame: CGRectMake(0, 0, 22, 22))
        likeImage.image = UIImage(named: "like_btn")
        self.likedView.addSubview(likeImage)
        
        self.likesCount = UILabel(frame: CGRectMake(26, 0, 54, 22))
        self.likesCount.textColor = Utils.sharedInstance.SW_PURPLE
        self.likesCount.font = UIFont.systemFontOfSize(14)
        self.likesCount.text = "\(good.likes)"
        self.likedView.addSubview(self.likesCount)
    }
    
    func setupDiscount(good: SWGood) {
        if good.discountPercent <= 0 {
            return
        }
        
        var discountLbl = UILabel(frame: CGRectMake(self.frame.size.width - 80, 0, 80, 22))
        discountLbl.autoresizingMask = .FlexibleLeftMargin
        discountLbl.textColor = UIColor.redColor()
        discountLbl.textAlignment = .Right
        discountLbl.font = UIFont.systemFontOfSize(14)
        discountLbl.text = "- \(good.discountPercent) %"
        self.addSubview(discountLbl)
    }
    
    func setupDetailInfo(good: SWGood) {
        var titleLbl = UILabel(frame: CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 20))
        titleLbl.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        titleLbl.textAlignment = .Center
        titleLbl.font = UIFont.systemFontOfSize(14)
        titleLbl.minimumScaleFactor = 0.6
        titleLbl.textColor = UIColor.grayColor()
        titleLbl.text = good.title
        self.addSubview(titleLbl)
        
        var priceLbl = UILabel(frame: CGRectMake(0, CGRectGetMaxY(titleLbl.frame), CGRectGetWidth(titleLbl.frame), 20))
        priceLbl.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        priceLbl.textAlignment = .Center
        priceLbl.font = UIFont.systemFontOfSize(14)
        priceLbl.minimumScaleFactor = 0.6
        priceLbl.textColor = UIColor.grayColor()
        self.addSubview(priceLbl)
        
        var detailTxt: NSString
        let oldPrice = Utils.sharedInstance.currencyStringFor(good.oldPrice)
        let price = Utils.sharedInstance.currencyStringFor(good.price)
        if good.oldPrice == good.price {
            detailTxt = "\(price) \(good.merchant)"
        } else {
            detailTxt = "\(oldPrice)   \(price) \(good.merchant)"
        }
        var attributedStr = NSMutableAttributedString(string: detailTxt as String)
        let oldPriceRng = detailTxt.rangeOfString(oldPrice)
        if good.oldPrice != good.price {
            attributedStr.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: oldPriceRng)
            attributedStr.addAttribute(NSStrikethroughColorAttributeName, value: UIColor.blackColor(), range: oldPriceRng)
        }
        let priceRng = detailTxt.rangeOfString(price, options: .BackwardsSearch)
        attributedStr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: priceRng)
        attributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: priceRng)
        priceLbl.attributedText = attributedStr
    }

}
