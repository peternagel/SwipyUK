//
//  BrandViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 20/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol BrandSelectDelegate {
    func brandsDidSelect(brands: [[String: AnyObject]]!)
}

class BrandViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var delegate: BrandSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var brandTbl: UITableView!
    @IBOutlet weak var searchAllBtn: UIButton!
    @IBOutlet weak var brandFld: UITextField!
    @IBOutlet weak var warningLbl: UILabel!
    var selectedBrands: [[String: AnyObject]]!
    var allBrandAry: [[String: AnyObject]]!
    var topBrandAry: [[String: AnyObject]]!
    var brandAry: [[String: AnyObject]]!
    var allBrandsCount = 0
    var searchingKeyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Marken"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        self.searchAllBtn.layer.cornerRadius = 4.0
        self.searchAllBtn.layer.masksToBounds = true
        self.searchAllBtn.layer.borderWidth = 1.0
        
        if selectedBrands == nil {
            selectedBrands = [[String: AnyObject]]()
        }
        
        let filterParams = APIClient.sharedInstance.getFilterParams(["brands", "user", "gender", "min", "max"])
        if filterParams.count == 0 {
            topBrandAry = [[String: AnyObject]]()
            let filter = Utils.sharedInstance.filterInfo
            var topBrands = filter["topBrands"] as! [String]
            for aBrand in topBrands {
                topBrandAry.append(["id": 0, "name": aBrand, "amount": 0])
            }
        }
        
        loadBrands()
        if selectedBrands.count == 0 {
            selectAllButton(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadBrands() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getBrands({ (brandsInfo: [String : AnyObject]) -> Void in
            self.allBrandsCount = brandsInfo["allBrands"] as! Int
            let brandsAry = brandsInfo["brands"] as! [[String: AnyObject]]
            self.allBrandAry = self.filterAmount(brandsAry)
            self.brandAry = self.allBrandAry
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.isTopBrand() {
                    self.setTopBrandAmount()
                }
                self.reloadTable()
            })
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func filterAmount(itemAry: [[String: AnyObject]]) -> [[String: AnyObject]] {
        var filteredAry = [[String: AnyObject]]()
        for item in itemAry {
            if let amount = item["amount"] as? Int {
                if amount > 0 {
                    filteredAry.append(item)
                }
            }
        }
        
        return filteredAry
    }
    
    func selectAllButton(selected: Bool) {
        var allTxt = NSLocalizedString("Search for all brands", comment: "")
        let amountTxt = "(\(allBrandsCount))"
        allTxt += " " + amountTxt
        let amountRng = (allTxt as NSString).rangeOfString(amountTxt, options: .BackwardsSearch)
        
        if selected {
            var allStr = NSMutableAttributedString(string: allTxt, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 14)!])
            allStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-BoldItalic", size: 14)!, range: amountRng)
            self.searchAllBtn.layer.borderColor = UIColor.blackColor().CGColor
            self.searchAllBtn.setAttributedTitle(allStr, forState: .Normal)
        } else {
            var allStr = NSMutableAttributedString(string: allTxt, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 14)!])
            allStr.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-ThinItalic", size: 14)!, range: amountRng)
            self.searchAllBtn.layer.borderColor = UIColor(white: 220/255.0, alpha: 1.0).CGColor
            self.searchAllBtn.setAttributedTitle(allStr, forState: .Normal)
        }
    }
    
    func setTopBrandAmount() {
        var amountTopAry = [[String: AnyObject]]()
        for topBrandItem in topBrandAry {
            var amount = 0
            if let topName = topBrandItem["name"] as? String {
                for brandItem in allBrandAry {
                    if let brandName = brandItem["name"] as? String {
                        if topName == brandName {
                            amount = brandItem["amount"] as! Int
                            break
                        }
                    }
                }
            }
            var amountItem = topBrandItem
            amountItem["amount"] = amount
            amountTopAry.append(amountItem)
        }
        topBrandAry = amountTopAry
    }
    
    func reloadTable() {
        brandTbl.reloadData()
        if brandAry == nil || brandAry.count == 0 {
            warningLbl.alpha = 1.0
            brandTbl.scrollEnabled = false
        } else {
            warningLbl.alpha = 0.0
            brandTbl.scrollEnabled = true
        }
        
        if selectedBrands == nil || selectedBrands.count == 0 {
            selectAllButton(true)
        } else {
            selectAllButton(false)
        }
        
        selectItems()
    }
    
    func selectItems() {
        if brandAry == nil {
            return
        }
        
        var allSection = 0
        if isTopBrand() {
            allSection = 1
            
            for item in selectedBrands {
                let itemName = item["name"] as! String
                for var i = 0; i < topBrandAry.count; i++ {
                    let brandName = topBrandAry[i]["name"] as! String
                    if itemName == brandName {
                        brandTbl.selectRowAtIndexPath(NSIndexPath(forRow: i + 1, inSection: 0), animated: false, scrollPosition: .None)
                    }
                }
            }
        }
        
        for item in selectedBrands {
            let itemName = item["name"] as! String
            for var i = 0; i < brandAry.count; i++ {
                let brandName = brandAry[i]["name"] as! String
                if itemName == brandName {
                    brandTbl.selectRowAtIndexPath(NSIndexPath(forRow: i + 1, inSection: allSection), animated: false, scrollPosition: .None)
                }
            }
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            /*let selectedIndexes = brandTbl.indexPathsForSelectedRows()
            var selectedItems = [String]()
            if selectedIndexes != nil {
                for aBrand in selectedIndexes as [NSIndexPath] {
                    selectedItems.append(brandAry[aBrand.row])
                }
            }*/
            delegate.brandsDidSelect(selectedBrands)
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
    
    @IBAction func onSearchAll(sender: AnyObject) {
        selectAllButton(true)
        selectedBrands = [[String: AnyObject]]()
        
        let selectedRows = brandTbl.indexPathsForSelectedRows!
        if selectedRows == nil {
            return
        }
        let selectedIndexes = selectedRows as [NSIndexPath]
        for anItem in selectedIndexes {
            brandTbl.deselectRowAtIndexPath(anItem, animated: true)
        }
    }
    
    func isTopBrand() -> Bool {
        return (topBrandAry != nil && count(searchingKeyword) == 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isTopBrand() {
            return 2
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTopBrand() && section == 0 {
            return 1 + topBrandAry.count
        }
        
        if brandAry != nil {
            return 1 + brandAry.count
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as UITableViewCell!
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
            if count(searchingKeyword) > 0 {
                cell.textLabel?.text = "Suchergebnisse"
            } else {
                if isTopBrand() && indexPath.section == 0 {
                    cell.textLabel?.text = NSLocalizedString("Top Brands", comment: "")
                } else {
                    cell.textLabel?.text = NSLocalizedString("All Brands", comment: "")
                }
            }
            
            return cell
        } else {
            var brandItem: [String: AnyObject]
            if isTopBrand() && indexPath.section == 0 {
                brandItem = topBrandAry[indexPath.row - 1]
            } else {
                brandItem = brandAry[indexPath.row - 1]
            }
            
            var cell = tableView.dequeueReusableCellWithIdentifier("BrandCell") as! BrandTableViewCell
            cell.config(brandItem)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isTopBrand() && indexPath.section == 0 {
            selectedBrands.append(topBrandAry[indexPath.row - 1])
        } else {
            selectedBrands.append(brandAry[indexPath.row - 1])
        }
        selectAllButton(false)
        selectItems()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            return
        }
        
        var currBrands: [[String: AnyObject]]!
        if isTopBrand() && indexPath.section == 0 {
            currBrands = topBrandAry
        } else {
            currBrands = brandAry
        }
        
        let brandName = currBrands[indexPath.row - 1]["name"] as! String
        var index: Int!
        for var i = 0; i < selectedBrands.count; i++ {
            let itemName = selectedBrands[i]["name"] as! String
            if itemName == brandName {
                index = i
                break
            }
        }
        if index != nil {
            selectedBrands.removeAtIndex(index)
        }
        if selectedBrands == nil || selectedBrands.count == 0 {
            selectAllButton(true)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text as NSString!
        let newText = oldText.stringByReplacingCharactersInRange(range, withString: string) as NSString
        newText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if newText.length == 0 {
            searchingKeyword = ""
            brandAry = allBrandAry
            reloadTable()
        } else {
            brandAry = nil
            searchingKeyword = newText as String
            reloadTable()
            if newText.length < 3 {
                warningLbl.text = "Bitte gebe für die Suche mindestens 3 Buchstaben ein!"
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    var filteredAry = [[String: AnyObject]]()
                    for brandItem in self.allBrandAry {
                        if let brandName = brandItem["name"] as? String {
                            if let searchRng = brandName.rangeOfString(newText as String, options: .CaseInsensitiveSearch) {
                                filteredAry.append(brandItem)
                            }
                        }
                    }
                    self.brandAry = filteredAry
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showBrands()
                    })
                }
            }
        }
        
        return true
    }
    
    func showBrands() {
        if brandAry == nil || brandAry.count == 0 {
            warningLbl.text = "Es wurden leider keine Marken gefunden!"
        }
        reloadTable()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
