//
//  WishlistViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 24/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol WishlistDelegate {
    func wishItemDeleted()
}

class WishlistViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: WishlistDelegate!
    var wishlist: [SWGood]!
    @IBOutlet weak var wishlistTbl: UITableView!
    @IBOutlet var headerViw: UIView!
    @IBOutlet weak var emptyTextViw: UITextView!
    var alert: BPCompatibleAlertController!
    var warningAlert: BPCompatibleAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let headerTxt = NSLocalizedString("Your Wishlist is empty...", comment: "")
        let bodyTxt = NSLocalizedString("If you like a style, swipe right and find it back here again!", comment: "")
        let emptyTxt = headerTxt + "\n\n" + bodyTxt as NSString
        var emptyStr = NSMutableAttributedString(string: emptyTxt as String, attributes: [NSForegroundColorAttributeName: UIColor(white: 56/255.0, alpha: 1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 13)!])
        let headerRng = emptyTxt.rangeOfString(headerTxt)
        emptyStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(28), range: headerRng)
        emptyTextViw.attributedText = emptyStr
        
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            self.wishlistTbl.estimatedRowHeight = 100.0
            self.wishlistTbl.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenName = "Wishlist View"
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        wishlist = Utils.sharedInstance.wishlist
        checkWishlistCount()
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenOpenWhishlist)
    }
    
    func checkWishlistCount() {
        if wishlist.count > 0 {
            wishlistTbl.alpha = 1.0
            emptyTextViw.alpha = 0.0
            self.wishlistTbl.reloadData()
            
            if wishlist.count < 4 {
                wishlistTbl.tableHeaderView = nil
            } else {
                wishlistTbl.tableHeaderView = headerViw
            }
        } else {
            wishlistTbl.alpha = 0.0
            emptyTextViw.alpha = 1.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onSendWishlist(sender: AnyObject) {
        alert = BPCompatibleAlertController(title: NSLocalizedString("Share wishlist via E-Mail", comment: ""), message: NSLocalizedString("Send your wishlist to you or to your friends and store your favorites styles!", comment: ""), alertStyle: .Alert)
        alert.alertViewStyle = .PlainTextInput
        alert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Back", comment: ""), handler: { (action:BPCompatibleAlertAction!) -> Void in
        }))
        alert.addAction(BPCompatibleAlertAction.defaultActionWithTitle(NSLocalizedString("Send", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            self.sendWishList(self.alert.textFieldAtIndex(0)?.text)
        }))
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.text = Utils.sharedInstance.emailAddress
        }
        alert.presentFrom(self.revealViewController(), animated: true) { () -> Void in
        }
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenSendWhishlist)
    }
    
    @IBAction func onResetWishlist(sender: AnyObject) {
        alert = BPCompatibleAlertController(title: NSLocalizedString("Clear Wishlist", comment: ""), message: NSLocalizedString("Are you sure you want to delete your Wishlist?", comment: ""), alertStyle: .Alert)
        alert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Back", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
        }))
        alert.addAction(BPCompatibleAlertAction.defaultActionWithTitle(NSLocalizedString("Delete", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            self.wishlist = [SWGood]()
            Utils.sharedInstance.resetWishlist()
            
            self.checkWishlistCount()
            
            if self.delegate != nil {
                self.delegate.wishItemDeleted()
            }
        }))
        alert.presentFrom(self.revealViewController(), animated: true) { () -> Void in
        }
    }
    
    func sendWishList(email: String!) {
        if email == nil || !email.isValidEmail() {
            warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Something went wrong", comment: ""), message: NSLocalizedString("Please provide a valid E-Mail address", comment: ""), alertStyle: .Alert)
            warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Try again", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
            }))
            warningAlert.presentFrom(self.revealViewController(), animated: true, completion: { () -> Void in
            })
            return
        }
        
        Utils.sharedInstance.emailAddress = email
        Utils.sharedInstance.saveEmailAddress()
        
        APIClient.sharedInstance.sendWishlist({ () -> Void in
            }, failure: { (error: NSError!) -> Void in
        })
        
        warningAlert = BPCompatibleAlertController(title: NSLocalizedString("Wishlist sent", comment: ""), message: NSLocalizedString("Perfect, it worked! Your wishlist is on its way to you.", comment: ""), alertStyle: .Alert)
        warningAlert.addAction(BPCompatibleAlertAction.cancelActionWithTitle(NSLocalizedString("Ok, Thanks!", comment: ""), handler: { (action: BPCompatibleAlertAction!) -> Void in
        }))
        warningAlert.presentFrom(self.revealViewController(), animated: true, completion: { () -> Void in
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishlist.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let wishCell = tableView.dequeueReusableCellWithIdentifier("WishCell") as! WishTableViewCell
        wishCell.configWithGood(wishlist[indexPath.row])
        wishCell.removeBtn.tag = indexPath.row
        wishCell.shopBtn.tag = indexPath.row
        
        return wishCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            return UITableViewAutomaticDimension
        }
        
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let wishItem = wishlist[indexPath.row]
        var detailCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! DetailViewController
        detailCtlr.currGood = wishItem
        var navCtlr = UINavigationController(rootViewController: detailCtlr)
        navCtlr.navigationBarHidden = true
        self.revealViewController().presentViewController(navCtlr, animated: true, completion: nil)
    }
    
    @IBAction func onRemoveItem(sender: UIButton) {
        let itemIndex = sender.tag
        wishlist.removeAtIndex(itemIndex)
        Utils.sharedInstance.removeWishitemAtIndex(itemIndex)
        
        checkWishlistCount()
        
        if self.delegate != nil {
            self.delegate.wishItemDeleted()
        }
    }
    
    @IBAction func onShopItem(sender: UIButton) {
        let wishItem = wishlist[sender.tag]
        var webCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
        webCtlr.linkData = wishItem
        webCtlr.presentMode = "Modal"
        self.revealViewController().pushModalViewController(webCtlr)
    }

}
