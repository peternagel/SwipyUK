//
//  ImprintViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 17/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class ImprintViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imprintTextViw: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backBtn.makeBackButton()
        
        let headerTxt = NSLocalizedString("Imprint", comment: "")
        var bodyTxt = headerTxt + "\nSwipy GmbH\nAn der Prinzenmauer 55\n35510 Butzbach\n\n"
        bodyTxt += NSLocalizedString("Represented by:", comment: "")
        bodyTxt += "\nBenjamin Bilski\nBjörn Scheurich\nAlexander Braune\nDavid Suppes\n\n"
        bodyTxt += NSLocalizedString("Contact", comment: "") + ": hello@swipy.de"
        var bodyStr = NSMutableAttributedString(string: bodyTxt, attributes: [NSForegroundColorAttributeName: UIColor(white: 56/255.0, alpha: 1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 14)!])
        let headerRng = (bodyTxt as NSString).rangeOfString(headerTxt)
        bodyStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 14)!, range: headerRng)
        imprintTextViw.attributedText = bodyStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
