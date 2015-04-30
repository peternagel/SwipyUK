//
//  RabatteViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol RebateSelectDelegate {
    func rebateDidSelect(rebate: [String: AnyObject]!)
}

class RabatteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: RebateSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var rebateTbl: UITableView!
    var initialRebate: [String: AnyObject]!
    var rebateAry: [[String: AnyObject]]!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Rabatte"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        rebateAry = [["id": -1, "amount": 0]]
        loadRabate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRabate() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getRebate({ (rebateInfo: [String : AnyObject]) -> Void in
            self.rebateAry[0]["amount"] = rebateInfo["allRebates"] as! Int
            self.rebateAry.extend(rebateInfo["rebates"] as! [[String: AnyObject]])
            self.rebateTbl.reloadData()
            self.selectInitialRebate()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func selectInitialRebate() {
        var index = 0
        if initialRebate != nil {
            let initialId = initialRebate["id"] as! Int
            for var i = 0; i < rebateAry.count; i++ {
                let rebateId = rebateAry[i]["id"] as! Int
                if rebateId == initialId {
                    index = i
                    break
                }
            }
        }
        self.rebateTbl.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            if let selectedRebate = rebateTbl.indexPathForSelectedRow() {
                let rebateItem = rebateAry[selectedRebate.row]
                delegate.rebateDidSelect(rebateItem)
            }
        }
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rebateAry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rebateItem = rebateAry[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("RebateCell") as! RabatteTableViewCell
        cell.config(rebateItem, isAll: (indexPath.row == 0))
        
        return cell
    }

}
