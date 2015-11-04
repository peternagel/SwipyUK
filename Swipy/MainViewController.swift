//
//  MainViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 24/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class MainViewController: GAITrackedViewController, SWRevealViewControllerDelegate, MDCSwipeToChooseDelegate, CardActionOnDetailDelegate, WishlistDelegate {
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var wishBtn: UIButton!
    @IBOutlet weak var wishlistCnt: UILabel!
    
    @IBOutlet weak var shoppingBagBtn: UIButton!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var overViw: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var errorViw: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var errorBtn: UIButton!
    
    var currGood: SWItem!
    var tapDetail: UITapGestureRecognizer!
    var tapCloseToRight: UITapGestureRecognizer!
    var tapCloseToLeft: UITapGestureRecognizer!
    var frontCard: SwipyView! {
        didSet {
            if frontCard != nil {
                self.currGood = frontCard.item
                frontCard.addGestureRecognizer(tapDetail)
                
                passBtn.hidden = false
                shoppingBagBtn.hidden = false
                likeBtn.hidden = false
            } else {
                passBtn.hidden = true
                shoppingBagBtn.hidden = true
                likeBtn.hidden = true
            }
        }
    }
    var belowCard: SwipyView!
    var goodAry = [SWItem]()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configOverView()
        
        var subWidth: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            subWidth = 640.0
        } else {
            subWidth = UIScreen.mainScreen().applicationFrame.size.width / 320.0 * 260.0
        }
        self.revealViewController().rearViewRevealWidth = subWidth
        self.revealViewController().rightViewRevealWidth = subWidth
        
        updateCount()
        
        self.revealViewController().delegate = self
        menuBtn.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
        wishBtn.addTarget(self.revealViewController(), action: "rightRevealToggle:", forControlEvents: .TouchUpInside)
        
        let wishNavCtlr = self.revealViewController().rightViewController as! UINavigationController
        var wishCtlr = wishNavCtlr.viewControllers[0] as! WishlistViewController
        wishCtlr.delegate = self
        
        tapDetail = UITapGestureRecognizer(target: self, action: "onInfo:")
        tapCloseToRight = UITapGestureRecognizer(target: self, action: "onCloseToRight:")
        tapCloseToLeft = UITapGestureRecognizer(target: self, action: "onCloseToLeft:")
        
        setupButtons()
        
        self.passBtn.hidden = true
        self.shoppingBagBtn.hidden = true
        self.likeBtn.hidden = true
        loadData()
        
        addObservers()
        
        Utils.sharedInstance.isMainViewLoaded = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenName = "Main View"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplinkForItem:", name: Utils.sharedInstance.kDeepLinkItemNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplinkForSpecial:", name: Utils.sharedInstance.kDeepLinkSpecialNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplinkForFilter:", name: Utils.sharedInstance.kDeepLinkFilterNotification, object: nil)
    }
    
    func configOverView() {
        let tapOverViw = UITapGestureRecognizer(target: self, action: "onCloseOverView:")
        overViw.addGestureRecognizer(tapOverViw)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let padFont = UIFont(name: "Gloria Hallelujah", size: 24)
            for subViw in overViw.subviews {
                if let subLbl = subViw as? UILabel {
                    subLbl.font = padFont
                }
            }
            closeBtn.titleLabel?.font = UIFont.fontAwesomeOfSize(50)
        }
        
        closeBtn.setTitle(String.fontAwesomeIconWithName(.Close), forState: .Normal)
        
        showOverView()
    }
    
    func revealController(revealController: SWRevealViewController!, animateToPosition position: FrontViewPosition) {
        showOverView()
        
        if APIClient.sharedInstance.shouldRestart {
            reloadProducts()
            APIClient.sharedInstance.shouldRestart = false
        }
    }
    
    func reloadProducts() {
        if frontCard != nil {
            frontCard.removeFromSuperview()
            frontCard = nil
        }
        if belowCard != nil {
            belowCard.removeFromSuperview()
            belowCard = nil
        }
        
        goodAry = [SWGood]()
        loadData()
    }
    
    func onCloseToRight(gesture: UIGestureRecognizer) {
        self.revealViewController().rightRevealToggleAnimated(true)
    }
    
    func onCloseToLeft(gesture: UIGestureRecognizer) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func showOverView() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("OverShownKey") {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.overViw.alpha = 1.0
            })
        }
    }
    
    @IBAction func onCloseOverView(sender: AnyObject) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.overViw.alpha = 0.0
            }) { (isFinished: Bool) -> Void in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "OverShownKey")
        }
    }
    
    func updateCount() {
        let wishItems = Utils.sharedInstance.wishlist.count
        self.wishlistCnt.text = "\(wishItems)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        if position == .Left {
            if self.frontCard != nil {
                self.frontCard.userInteractionEnabled = true
            }
            if self.belowCard != nil {
                self.belowCard.userInteractionEnabled = true
            }
            self.view.removeGestureRecognizer(tapCloseToLeft)
            self.view.removeGestureRecognizer(tapCloseToRight)
        } else {
            if self.frontCard != nil {
                self.frontCard.userInteractionEnabled = false
            }
            if self.belowCard != nil {
                self.belowCard.userInteractionEnabled = false
            }
            if position == .LeftSide {
                self.view.addGestureRecognizer(tapCloseToRight)
            } else if position == .Right {
                self.view.addGestureRecognizer(tapCloseToLeft)
            }
        }
    }
    
    func setupButtons() {
        self.shoppingBagBtn.layer.cornerRadius = self.shoppingBagBtn.frame.size.width / 2.0
        self.shoppingBagBtn.layer.masksToBounds = true
        self.shoppingBagBtn.layer.borderWidth = 1.0
        self.shoppingBagBtn.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
        
        self.passBtn.layer.cornerRadius = self.passBtn.frame.size.width / 2.0
        self.passBtn.layer.masksToBounds = true
        self.passBtn.layer.borderWidth = 1.0
        self.passBtn.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
        
        self.likeBtn.layer.cornerRadius = self.likeBtn.frame.size.width / 2.0
        self.likeBtn.layer.masksToBounds = true
        self.likeBtn.layer.borderWidth = 1.0
        self.likeBtn.layer.borderColor = Utils.sharedInstance.SW_PURPLE.CGColor
    }
    
    func loadData() {
        errorViw.alpha = 0.0
        Utils.sharedInstance.showHUD(self.view)
        isLoading = true
        
        APIClient.sharedInstance.getGoods(
            { (result: [SWItem]) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Utils.sharedInstance.hideHUD()
                    
                    if result.count == 0 {
                        self.errorViw.alpha = 1.0
                        self.errorLbl.text = "Wir konnten leider keine Produkte finden. Bitte ändere Deine Filter- und Shop-Einstellungen."
                        self.errorBtn.alpha = 0.0
                    } else {
                        self.goodAry.extend(result)
                        
                        if self.frontCard == nil {
                            self.frontCard = self.popGoodViewWithFrame(self.frontCardFrame())
                            if self.frontCard != nil {
                                self.view.insertSubview(self.frontCard, belowSubview: self.overViw)
                            }
                        }
                        
                        if self.belowCard == nil {
                            self.belowCard = self.popGoodViewWithFrame(self.belowCardFrame())
                            if self.belowCard != nil {
                                self.view.insertSubview(self.belowCard, belowSubview: self.frontCard)
                            }
                        }
                    }
                    self.isLoading = false
                })
                
            }, failure:{ (error: NSError!) -> Void in
                print("Error: " + error.localizedDescription)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    Utils.sharedInstance.hideHUD()
                    
                    self.errorViw.alpha = 1.0
                    self.errorLbl.text = "Ups! Sieht so aus, als hättest Du keine Internetverbindung!"
                    self.errorBtn.alpha = 1.0
                    
                    self.isLoading = false
                })
        })
    }
    
    @IBAction func onErrorRetry(sender: AnyObject) {
        loadData()
    }
    
    /*
    func configSwipyView() {
        if swipyView != nil {
            swipyView.removeFromSuperview()
        }
    
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.threshold = 100
        swipyView = MDCSwipeToChooseView(frame:CGRectMake(20, 100, 280, 300), options:options)
        swipyView.imageView.image = UIImage(named: "zalando sale")
    }
    */
    @IBAction func onPass(sender: AnyObject) {
        frontCard.mdc_swipe(.Left)
    }
    
    @IBAction func onLike(sender: AnyObject) {
        frontCard.mdc_swipe(.Right)
    }
    
    @IBAction func onInfo(sender: AnyObject) {
        if let good = self.currGood as? SWGood {
            var detailCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
            detailCtlr.currGood = good
            detailCtlr.delegate = self
            var navCtlr = UINavigationController(rootViewController: detailCtlr)
            navCtlr.navigationBarHidden = true
            self.presentViewController(navCtlr, animated: true, completion: nil)
        }
    }
    
    @IBAction func onShoppingBag(sender: AnyObject) {
        if let good = self.currGood as? SWGood {
            var webCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
            webCtlr.linkData = self.currGood
            webCtlr.presentMode = "Modal"
            self.revealViewController().pushModalViewController(webCtlr)
        }
    }
    
    // MARK: - CardActionOnDetail
    func cardDidLikeOnDetail() {
        if self.frontCard != nil {
            self.frontCard.mdc_swipe(.Right)
        }
    }
    
    func cardDidPassOnDetail() {
        if self.frontCard != nil {
            self.frontCard.mdc_swipe(.Left)
        }
    }
    
    // MARK: - WishlistDelegate
    func wishItemDeleted() {
        updateCount()
    }

    // MARK: - MDCSwipeToChooseDelegate
    func viewDidCancelSwipe(view: UIView!) {
        print("You couldn't decide")
    }
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        if direction == .Right {
            if let good = frontCard.item as? SWGood {
                Utils.sharedInstance.insertWishitem(good)
                updateCount()
            }
            
            Utils.sharedInstance.appendTracking("likes", itemId: frontCard.item.itemId)
            
            Utils.trackAdjustEvent(Utils.adjustEventTokenLike)
        } else {
            Utils.sharedInstance.appendTracking("dislikes", itemId: frontCard.item.itemId)
            
            Utils.trackAdjustEvent(Utils.adjustEventTokenDislike)
        }
        
        self.frontCard = self.belowCard
        self.belowCard = self.popGoodViewWithFrame(self.belowCardFrame())
        if self.belowCard != nil {
            self.belowCard.alpha = 0.0
            self.view.insertSubview(self.belowCard, belowSubview: self.frontCard)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.belowCard.alpha = 1.0
            })
        }
    }
    
    func frontCardFrame() -> CGRect {
        let hPadding: CGFloat = 20.0
        let topPadding: CGFloat = 80.0
        let bottomPadding: CGFloat = 160.0
        
        return CGRectMake(hPadding, topPadding, self.view.frame.size.width - 2*hPadding, self.view.frame.size.height - bottomPadding)
    }
    
    func belowCardFrame() -> CGRect {
        return self.frontCardFrame()
    }
    
    func popGoodViewWithFrame(frame: CGRect) -> SwipyView! {
        if self.goodAry.count == 0 {
            return nil
        }
        
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.threshold = 60.0
        
        var swipyView = SwipyView(frame: frame, goodInfo: self.goodAry[0], options: options)
        self.goodAry.removeAtIndex(0)
        
        if self.goodAry.count < 2 {
            self.loadData()
        }
        
        return swipyView
    }
    
    func deeplinkForItem(notification: NSNotification) {
        let itemId = notification.userInfo!["id"] as! String
        
        APIClient.sharedInstance.getGoodForId(itemId, success: { (good: SWGood!) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.appendNewItem(good)
            })
            }) { (error: NSError!) -> Void in
        }
    }
    
    func dismissAllView() {
        let presented = self.presentedViewController
        if presented != nil {
            presented?.dismissViewControllerAnimated(false, completion: nil)
        }
        
        self.revealViewController().setFrontViewPosition(.Left, animated: false)
    }
    
    func appendNewItem(good: SWGood) {
        while isLoading {
            sleep(1)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.dismissAllView()
            
            if self.belowCard != nil {
                self.goodAry.insert(self.belowCard.item, atIndex: 0)
                self.belowCard.removeFromSuperview()
            }
            
            self.belowCard = self.frontCard
            if self.belowCard != nil {
                self.belowCard.frame = self.belowCardFrame()
            }
            
            self.goodAry.insert(good, atIndex: 0)
            self.frontCard = self.popGoodViewWithFrame(self.frontCardFrame())
            self.view.insertSubview(self.frontCard, belowSubview: self.overViw)
        })
    }
    
    func deeplinkForSpecial(notification: NSNotification) {
        dismissAllView()
        reloadProducts()
    }
    
    func deeplinkForFilter(notification: NSNotification) {
        dismissAllView()
        reloadProducts()
    }
    
}
