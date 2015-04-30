//
//  WebViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 06/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    var linkData: AnyObject!
    var urlLink: String!
    var presentMode = "Push"
    @IBOutlet weak var webViw: UIWebView!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var forwardItem: UIBarButtonItem!
    @IBOutlet var refreshItem: UIBarButtonItem!
    @IBOutlet var stopItem: UIBarButtonItem!
    @IBOutlet weak var shareItem: UIBarButtonItem!
    var shareSheet: BPCompatibleAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        shareItem.enabled = Utils.canShareViaWhatsApp()
        
        if let goodInfo = linkData as? SWGood {
            urlLink = goodInfo.link
            Utils.sharedInstance.appendTracking("openLinks", itemId: goodInfo.itemId)
        } else if let urlInfo = linkData as? String {
            urlLink = urlInfo
        }
        self.webViw.loadRequest(NSURLRequest(URL: NSURL(string: urlLink)!))
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
    
    @IBAction func onBack(sender: AnyObject) {
        self.webViw.stopLoading()
        if self.presentMode == "Push" {
            self.navigationController?.popViewControllerAnimated(true)
        } else if self.presentMode == "Modal" {
            self.popModalControllerAnimated()
        }
    }
    
    @IBAction func onSafari(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: urlLink)!)
    }

    @IBAction func onBackBrowse(sender: AnyObject) {
        self.webViw.goBack()
    }
    
    @IBAction func onForwardBrowse(sender: AnyObject) {
        self.webViw.goForward()
    }
    
    @IBAction func onRefresh(sender: AnyObject) {
        self.webViw.reload()
    }
    
    @IBAction func onStop(sender: AnyObject) {
        self.webViw.stopLoading()
    }
    
    @IBAction func onShare(sender: AnyObject) {
        shareSheet = BPCompatibleAlertController(title: "Zeig's Deinen Freunden", message: nil, alertStyle: .Actionsheet)
        shareSheet.addAction(BPCompatibleAlertAction.defaultActionWithTitle("Über WhatsApp teilen", handler: { (action: BPCompatibleAlertAction!) -> Void in
            if let goodInfo = self.linkData as? SWGood {
                let shareLink = "http://swipy.it/\(goodInfo.itemId)"
                Utils.shareLinkViaWhatsApp(shareLink)
            } else if let urlInfo = self.linkData as? String {
                Utils.shareLinkViaWhatsApp(urlInfo)
            }
        }))
        shareSheet.addAction(BPCompatibleAlertAction.cancelActionWithTitle("Abbrechen", handler: { (action: BPCompatibleAlertAction!) -> Void in
        }))
        shareSheet.presentFrom(self, animated: true) { () -> Void in
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        // Utils.sharedInstance.showHUD(self.view, autoHide: true)
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.bottomBar.items = [self.backItem, flexibleItem, self.forwardItem, flexibleItem, self.stopItem, flexibleItem, self.shareItem]
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.backItem.enabled = self.webViw.canGoBack
        self.forwardItem.enabled = self.webViw.canGoForward
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.bottomBar.items = [self.backItem, flexibleItem, self.forwardItem, flexibleItem, self.refreshItem, flexibleItem, self.shareItem]
        
        // Utils.sharedInstance.hideHUD()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.bottomBar.items = [self.backItem, flexibleItem, self.forwardItem, flexibleItem, self.refreshItem, flexibleItem, self.shareItem]
        
        // Utils.sharedInstance.hideHUD()
    }
    
}
