//
//  DetailViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 03/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol CardActionOnDetailDelegate {
    func cardDidLikeOnDetail()
    func cardDidPassOnDetail()
}

class DetailViewController: GAITrackedViewController, UIScrollViewDelegate {

    var delegate: CardActionOnDetailDelegate!
    
    @IBOutlet weak var topViw: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var imageScrollViw: UIScrollView!
    @IBOutlet weak var imagePager: UIPageControl!
    @IBOutlet weak var likeViw: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var detailViw: UIView!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var shippingCostLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var soldByLbl: UILabel!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var returnPolicyLbl: UILabel!
    @IBOutlet weak var bottomViw: UIView!
    @IBOutlet weak var shopBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    var currGood: SWGood!
    
    var shareSheet: BPCompatibleAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Utils.sharedInstance.appendTracking("viewDetails", itemId: currGood.itemId)
        
        // Do any additional setup after loading the view.
        if self.delegate == nil {
            self.passBtn.hidden = true
            self.likeBtn.hidden = true
        }
        
        setupBorders()
        setupButtons()
        setupLikes()
        setupDiscount()
        setupDetailInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenName = "Product Detail View"
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenOpenProductDetail)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.topViw.addBottomBorderWithHeight(1.0, andColor: UIColor.blackColor())
        self.bottomViw.addTopBorderWithHeight(1.0, andColor: UIColor.blackColor())
        
        setupImageViews()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var webCtlr = segue.destinationViewController as! WebViewController
        webCtlr.linkData = self.currGood
    }
    
    @IBAction func onClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLike(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.cardDidLikeOnDetail()
            }
        })
    }
    
    @IBAction func onPass(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.cardDidPassOnDetail()
            }
        })
    }
    
    func setupBorders() {
        self.view.layer.borderWidth = 2.0
        self.view.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func setupButtons() {
        self.likeBtn.layer.cornerRadius = self.likeBtn.frame.size.width / 2.0
        self.likeBtn.layer.masksToBounds = true
        self.likeBtn.layer.borderWidth = 1.5
        self.likeBtn.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
        
        self.passBtn.layer.cornerRadius = self.passBtn.frame.size.width / 2.0
        self.passBtn.layer.masksToBounds = true
        self.passBtn.layer.borderWidth = 1.5
        self.passBtn.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
        
        self.shopBtn.layer.cornerRadius = 4.0
        self.shopBtn.layer.masksToBounds = true
        self.shopBtn.layer.borderWidth = 1.5
        self.shopBtn.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.shareBtn.hidden = !Utils.canShareViaWhatsApp()
    }
/*
    // MARK: - KIImagePagerDataSource
    func arrayWithImages() -> [AnyObject]! {
        return self.currGood.images
    }
    
    func contentModeForImage(image: UInt) -> UIViewContentMode {
        return .ScaleAspectFit
    }
    
    // MARK: - KIImagePagerDelegate
    func imagePager(imagePager: KIImagePager!, didSelectImageAtIndex index: UInt) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    */
    
    @IBAction func onTapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupImageViews() {
        for oldView in imageScrollViw.subviews {
            if let aView = oldView as? UIImageView {
                if aView.tag == 100 {
                    aView.removeFromSuperview()
                }
            }
        }
        
        // print(self.view.bounds)
        var itemFrame = imageScrollViw.bounds
        itemFrame.origin = CGPointZero
        for imageLink in currGood.images {
            let imageViw = UIImageView(frame: itemFrame)
            imageViw.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            imageViw.contentMode = .ScaleAspectFit
            let imageUrl = NSURL(string: imageLink)
            imageViw.sd_setImageWithURL(imageUrl, placeholderImage: nil, options: .CacheMemoryOnly)
            imageViw.tag = 100
            imageScrollViw.addSubview(imageViw)
            
            itemFrame = CGRectOffset(itemFrame, itemFrame.width, 0)
        }
        imageScrollViw.contentSize = CGSizeMake(itemFrame.minX, 0)
        imageScrollViw.contentOffset = CGPointZero
        
        imagePager.numberOfPages = currGood.images.count
        imagePager.currentPage = 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        imagePager.currentPage = Int(page)
    }
    
    func setupLikes() {
        if self.currGood.likes <= 0 {
            self.likeViw.alpha = 0.0
        }
        
        self.likeLbl.text = "\(self.currGood.likes)"
    }
    
    func setupDiscount() {
        if self.currGood.discountPercent <= 0 {
            self.discountLbl.alpha = 0.0
        }
        
        self.discountLbl.text = "- \(self.currGood.discountPercent) %"
    }
    
    func setupDetailInfo() {
        self.titleLbl.text = self.currGood.title
        
        var detailTxt: NSString
        let oldPrice = Utils.sharedInstance.currencyStringFor(self.currGood.oldPrice)
        let price = Utils.sharedInstance.currencyStringFor(self.currGood.price)
        if self.currGood.oldPrice == self.currGood.price {
            detailTxt = "\(price) \(self.currGood.merchant)"
        } else {
            detailTxt = "\(oldPrice)   \(price) \(self.currGood.merchant)"
        }
        var attributedStr = NSMutableAttributedString(string: detailTxt as String)
        if self.currGood.oldPrice != self.currGood.price {
            attributedStr.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: detailTxt.rangeOfString(oldPrice))
            attributedStr.addAttribute(NSStrikethroughColorAttributeName, value: UIColor.blackColor(), range: detailTxt.rangeOfString(oldPrice))
        }
        attributedStr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: detailTxt.rangeOfString(price))
        attributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: detailTxt.rangeOfString(price))
        priceLbl.attributedText = attributedStr
        
        // self.detailViw.layer.borderWidth = 1.0
        // self.detailViw.layer.borderColor = UIColor(white: 218/255.0, alpha: 1.0).CGColor
        
        var sizeStr = ", ".join(self.currGood.sizes)
        if sizeStr.isEmpty {
            sizeStr = NSLocalizedString("See Shop", comment: "")
        }
        self.sizeLbl.text = sizeStr
        
        var deliveryStr = self.currGood.deliveryTime
        if deliveryStr.isEmpty {
            deliveryStr = NSLocalizedString("See Shop", comment: "")
        }
        self.deliveryLbl.text = deliveryStr
        
        var shippingCostStr = self.currGood.merchantObj["shippingCost"]
        if shippingCostStr == nil || shippingCostStr!.isEmpty {
            shippingCostStr = NSLocalizedString("See Shop", comment: "")
        }
        self.shippingCostLbl.text = shippingCostStr
        
        self.descriptionLbl.text = self.currGood.goodDesc
        
        var soldByStr = self.currGood.merchantObj["name"]
        if soldByStr == nil || soldByStr!.isEmpty {
            soldByStr = NSLocalizedString("See Shop", comment: "")
        }
        self.soldByLbl.text = soldByStr
        
        var paymentStr = self.currGood.merchantObj["paymentMethod"]
        if paymentStr == nil || paymentStr!.isEmpty {
            paymentStr = NSLocalizedString("See Shop", comment: "")
        }
        self.paymentMethodLbl.text = paymentStr
        
        var returnStr = self.currGood.merchantObj["returnPolicy"]
        if returnStr == nil || returnStr!.isEmpty {
            returnStr = NSLocalizedString("See Shop", comment: "")
        }
        self.returnPolicyLbl.text = returnStr
    }
    
    @IBAction func onShare(sender: AnyObject) {
        shareSheet = BPCompatibleAlertController(title: NSLocalizedString("Share it with your friends!", comment: ""), message: nil, alertStyle: .Actionsheet)
        shareSheet.addAction(BPCompatibleAlertAction.defaultActionWithTitle(NSLocalizedString("Share using WhatsApp", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            let shareLink = "http://swipy.it/\(self.currGood.itemId)"
            Utils.shareLinkViaWhatsApp(shareLink)
        }))
        shareSheet.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Cancel", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
        }))
        shareSheet.presentFrom(self, animated: true) { () -> Void in
        }
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenShareWhatsapp)
    }
    
}
