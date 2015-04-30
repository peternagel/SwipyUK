//
//  FilterNavigationViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 24/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class FilterNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var titleLbl = UILabel(frame: CGRectMake(0, 20, self.revealViewController().rearViewRevealWidth, 44))
        titleLbl.backgroundColor = UIColor.blackColor()
        titleLbl.textColor = Utils.sharedInstance.SW_PURPLE
        titleLbl.textAlignment = .Center
        titleLbl.font = UIFont.boldSystemFontOfSize(17)
        titleLbl.text = "Filter"
        self.view.addSubview(titleLbl)
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

}
