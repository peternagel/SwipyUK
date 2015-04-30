//
//  PriceViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol PriceSelectDelegate {
    func priceDidSelect(minPrice: Int, maxPrice: Int)
}

class PriceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var delegate: PriceSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var priceTbl: UITableView!
    @IBOutlet weak var minPriceFld: UITextField!
    @IBOutlet weak var maxPriceFld: UITextField!
    var initialMinPrice: Int!
    var initialMaxPrice: Int!
    var priceAry: [[String: AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Preise"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        priceAry = [["min": 0, "max": 0, "amount": 0]]
        if initialMinPrice != nil && initialMinPrice > 0 {
            minPriceFld.text = "\(initialMinPrice)"
        }
        if initialMaxPrice != nil && initialMaxPrice > 0 {
            maxPriceFld.text = "\(initialMaxPrice)"
        }
        loadPrices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPrices() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getPrices({ (priceInfo: [String : AnyObject]) -> Void in
            self.priceAry[0]["amount"] = priceInfo["allPrices"] as! Int
            self.priceAry.extend(priceInfo["prices"] as! [[String: AnyObject]])
            self.priceTbl.reloadData()
            // self.selectInitialRebate()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            var minPrice = minPriceFld.text.toInt()
            var maxPrice = maxPriceFld.text.toInt()
            if minPrice == nil || minPrice < 0 {
                minPrice = 0
            }
            if maxPrice == nil || maxPrice < 0 {
                maxPrice = 0
            }
            if maxPrice > 0 && maxPrice < minPrice {
                swap(&maxPrice, &minPrice)
            }
            delegate.priceDidSelect(minPrice!, maxPrice: maxPrice!)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceAry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let priceItem = priceAry[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PriceCell") as! PriceTableViewCell
        cell.config(priceItem, isAll: (indexPath.row == 0))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let priceItem = priceAry[indexPath.row]
        
        if let minVal = priceItem["min"] as? Int {
            if minVal > 0 {
                minPriceFld.text = "\(minVal)"
            } else {
                minPriceFld.text = ""
            }
        } else {
            minPriceFld.text = ""
        }
        
        if let maxVal = priceItem["max"] as? Int {
            if maxVal > 0 {
                maxPriceFld.text = "\(maxVal)"
            } else {
                maxPriceFld.text = ""
            }
        } else {
            maxPriceFld.text = ""
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
