//
//  MenuViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 24/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class MenuViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CategorySelectDelegate, SizeSelectDelegate, RebateSelectDelegate, PriceSelectDelegate, ColorSelectDelegate, BrandSelectDelegate, ShopSelectDelegate {

    @IBOutlet weak var filterTbl: UITableView!
    var specialAry = [AnyObject]()
    var keyAry = [String]()
    let MAX_KEYWORDS = 4
    var linkAry: [[String: Any]]!
    let kIcon = "IconKey"
    let kTitle = "TitleKey"
    var filterSetting: [String: AnyObject]!
    var specialCounts: [[String: String]]!
    var allOfferCount = 0
    var editingKeyIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            self.filterTbl.estimatedRowHeight = 50.0
            self.filterTbl.rowHeight = UITableViewAutomaticDimension
        }
        
        self.linkAry = [[kIcon: FontAwesome.FacebookSquare, kTitle: NSLocalizedString("Facebook", comment: "")], [kIcon: FontAwesome.Instagram, kTitle: NSLocalizedString("Instagram", comment: "")], [kIcon: FontAwesome.Book, kTitle: NSLocalizedString("Magazine", comment: "")], [kIcon: FontAwesome.Globe, kTitle: NSLocalizedString("Homepage", comment: "")], [kIcon: FontAwesome.Legal, kTitle: NSLocalizedString("Imprint", comment: "")]]
        
        loadFilter()
        updateFilterCount()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deeplinkForFilter:", name: Utils.sharedInstance.kDeepLinkFilterNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenName = "Filter View"
        
        editingKeyIndex = -1
        filterTbl.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        
        self.navigationController?.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        updateFilterCount()
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenOpenFilter)
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
    
    func loadFilter() {
        filterSetting = Utils.sharedInstance.filterSetting
        if let keys = filterSetting["keywords"] as? [String] {
            keyAry = keys
        }
        
        let filter = Utils.sharedInstance.filterInfo
        specialAry = filter["specials"] as! [AnyObject]
        
        filterTbl.reloadData()
    }
    
    func deeplinkForFilter(notification: NSNotification) {
        loadFilter()
        updateFilterCount()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return specialAry.count// + 1
        } else if section == 1 {
            return 2 + keyAry.count + (keyAry.count < MAX_KEYWORDS ? 1 : 0)
        } else if section == 2 {
            return 7
        } else if section == 3 {
            return 5 + linkAry.count
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpecialCell") as! SpecialTableViewCell
            if indexPath.row < specialAry.count {
                let specialItem = specialAry[indexPath.row] as! [String: AnyObject]
                cell.config(specialItem, counts: specialCounts)
            }/* else {
                cell.titleLbl.text = "Swipaholic Magazine"
            }*/
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("TextCell") as! UITableViewCell
                
                return cell
            }
            if indexPath.row == 1 {
                var cell = tableView.dequeueReusableCellWithIdentifier("GenderCell") as! GenderTableViewCell
                let gender = filterSetting["gender"] as! String
                if gender == "f" {
                    cell.genderSelector.selectedSegmentIndex = 0
                } else {
                    cell.genderSelector.selectedSegmentIndex = 1
                }
                
                return cell
            }
            if 2 <= indexPath.row && indexPath.row < 2 + keyAry.count {
                let keyText = keyAry[indexPath.row - 2]
                if indexPath.row - 2 == editingKeyIndex {
                    var cell = tableView.dequeueReusableCellWithIdentifier("KeyInputCell") as! KeyInputTableViewCell
                    cell.keyFld.text = keyText
                    cell.keyFld.tag = indexPath.row
                    
                    return cell
                } else {
                    var cell = tableView.dequeueReusableCellWithIdentifier("KeyCell") as! KeyTableViewCell
                    cell.keyLbl.text = keyText
                    cell.deleteBtn.tag = indexPath.row - 2
                    
                    return cell
                }
            }
            
            var cell = tableView.dequeueReusableCellWithIdentifier("KeyInputCell") as! KeyInputTableViewCell
            cell.keyFld.text = ""
            cell.keyFld.tag = indexPath.row
            
            return cell
        } else if indexPath.section == 2 {
            var cell = tableView.dequeueReusableCellWithIdentifier("FilterCell") as! FilterTableViewCell
            cell.config(filterSetting, index: indexPath.row)
            
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row < 2 {
                var cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as! ButtonTableViewCell
                if indexPath.row == 0 {
                    let titleTxt = NSLocalizedString("Show", comment: "")
                    let amountTxt = "(\(allOfferCount))"
                    let totalTxt = titleTxt + " " + amountTxt as NSString
                    var textColor: UIColor
                    if allOfferCount > 0 {
                        cell.titleBtn.enabled = true
                        textColor = UIColor.whiteColor()
                    } else {
                        cell.titleBtn.enabled = false
                        textColor = UIColor.grayColor()
                    }
                    var totalStr = NSMutableAttributedString(string: totalTxt as String, attributes: [NSForegroundColorAttributeName: textColor])
                    let amountRng = totalTxt.rangeOfString(amountTxt, options: .BackwardsSearch)
                    totalStr.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFontOfSize(14), range: amountRng)
                    cell.titleBtn.setAttributedTitle(totalStr, forState: .Normal)
                } else if indexPath.row == 1 {
                    let titleStr = NSMutableAttributedString(string: NSLocalizedString("Reset Filter", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
                    cell.titleBtn.setAttributedTitle(titleStr, forState: .Normal)
                    cell.titleBtn.enabled = true
                }
                cell.titleBtn.tag = indexPath.row
                
                return cell
            }
            if indexPath.row == 2 {
                var cell = tableView.dequeueReusableCellWithIdentifier("NormalCell") as! NormalTableViewCell
                cell.titleBtn.setTitle(NSLocalizedString("How it works", comment: ""), forState: .Normal)
                
                return cell
            }
            if indexPath.row == 3 {
                var cell = tableView.dequeueReusableCellWithIdentifier("LabelCell") as! LabelTableViewCell
                cell.titleLbl.text = NSLocalizedString("Follow Us!", comment: "")
                
                return cell
            }
            if indexPath.row < 4 + linkAry.count {
                let linkItem = linkAry[indexPath.row - 4] as [String: Any]
                var cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! LinkTableViewCell
                cell.iconLbl.text = String.fontAwesomeIconWithName(linkItem[kIcon] as! FontAwesome)
                cell.titleLbl.text = linkItem[kTitle] as? String
                
                return cell
            }
            if indexPath.row == 4 + linkAry.count {
                var cell = tableView.dequeueReusableCellWithIdentifier("FooterCell") as! FooterTableViewCell
                cell.titleLbl.text = "Version: " + UIApplication.appVersion()
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            return UITableViewAutomaticDimension
        }
        
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 12.0
        }
        
        return 0.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            var headerViw = UIView(frame: CGRectMake(0, 0, 10, 12))
            return headerViw
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row < specialAry.count {
                let specialItem = specialAry[indexPath.row] as! [String: AnyObject]
                APIClient.sharedInstance.specialId = specialItem["id"] as! Int
                APIClient.sharedInstance.shouldRestart = true
                self.revealViewController().revealToggleAnimated(true)
            }/* else {
                var webCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
                webCtlr.linkData = "http://www.swipaholic.de"
                webCtlr.presentMode = "Modal"
                self.revealViewController().pushModalViewController(webCtlr)
            }*/
        } else if indexPath.section == 1 {
            if 2 <= indexPath.row && indexPath.row < 2 + keyAry.count {
                editingKeyIndex = indexPath.row - 2
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                // tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                makeInputForEdtingKey()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                var categoryCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryView") as! CategoryViewController
                categoryCtlr.delegate = self
                categoryCtlr.initialCategory = filterSetting["mainCategory"] as! [String: AnyObject]!
                categoryCtlr.initialSubCategories = filterSetting["subCategories"] as! [[String: AnyObject]]!
                self.navigationController?.pushViewController(categoryCtlr, animated: true)
            } else if indexPath.row == 1 {
                var sizeCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("SizeView") as! SizeViewController
                sizeCtlr.delegate = self
                sizeCtlr.initialSizes = filterSetting["sizes"] as! [[String: AnyObject]]!
                self.navigationController?.pushViewController(sizeCtlr, animated: true)
            } else if indexPath.row == 2 {
                var rebateCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("RebateView") as! RabatteViewController
                rebateCtlr.delegate = self
                rebateCtlr.initialRebate = filterSetting["rebate"] as! [String: AnyObject]!
                self.navigationController?.pushViewController(rebateCtlr, animated: true)
            } else if indexPath.row == 3 {
                var priceCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("PriceView") as! PriceViewController
                priceCtlr.delegate = self
                priceCtlr.initialMinPrice = filterSetting["min"] as! Int
                priceCtlr.initialMaxPrice = filterSetting["max"] as! Int
                self.navigationController?.pushViewController(priceCtlr, animated: true)
            } else if indexPath.row == 4 {
                var colorCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("ColorView") as! ColorViewController
                colorCtlr.delegate = self
                colorCtlr.initialColors = filterSetting["colors"] as! [[String: AnyObject]]!
                self.navigationController?.pushViewController(colorCtlr, animated: true)
            } else if indexPath.row == 5 {
                var brandCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("BrandView") as! BrandViewController
                brandCtlr.delegate = self
                brandCtlr.selectedBrands = filterSetting["brands"] as! [[String: AnyObject]]!
                self.navigationController?.pushViewController(brandCtlr, animated: true)
            } else if indexPath.row == 6 {
                var shopCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("ShopView") as! ShopViewController
                shopCtlr.delegate = self
                shopCtlr.initialShops = filterSetting["shops"] as! [[String: AnyObject]]!
                self.navigationController?.pushViewController(shopCtlr, animated: true)
            }
        } else if indexPath.section == 3 {
            if 4 <= indexPath.row && indexPath.row < 4 + linkAry.count - 1 {
                var webCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("WebView") as! WebViewController
                if indexPath.row == 4 {
                    webCtlr.linkData = "http://facebook.com/swipyde"
                } else if indexPath.row == 5 {
                    webCtlr.linkData = "http://instagram.com/swipy_de"
                } else if indexPath.row == 6 {
                    webCtlr.linkData = "http://www.swipaholic.de"
                } else if indexPath.row == 7 {
                    webCtlr.linkData = "http://www.swipy.de"
                }
                webCtlr.presentMode = "Modal"
                self.revealViewController().pushModalViewController(webCtlr)
            } else if indexPath.row == 4 + linkAry.count - 1 {
                var imprintCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("ImprintView") as! UIViewController
                self.navigationController?.pushViewController(imprintCtlr, animated: true)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func makeInputForEdtingKey() {
        if 0 <= editingKeyIndex && editingKeyIndex < keyAry.count {
            let keyInputCell = filterTbl.cellForRowAtIndexPath(NSIndexPath(forRow: 2 + editingKeyIndex, inSection: 1)) as! KeyInputTableViewCell
            keyInputCell.keyFld.becomeFirstResponder()
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let inputCell = textField.superview?.superview as! KeyInputTableViewCell
        inputCell.showSelectButton(true)
        self.filterTbl.scrollToRowAtIndexPath(NSIndexPath(forRow: textField.tag, inSection: 1), atScrollPosition: .Middle, animated: true)
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        editingKeyIndex = -1
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let inputCell = textField.superview?.superview as! KeyInputTableViewCell
        inputCell.showSelectButton(false)
        
        let keyword = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        textField.text = ""
        if keyword.isEmpty {
            return
        }
        
        if 2 <= textField.tag && textField.tag < 2 + keyAry.count {
            keyAry[textField.tag - 2] = keyword
        } else if keyAry.count < MAX_KEYWORDS {
            keyAry.append(keyword)
        }
        filterTbl.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        filterSetting["keywords"] = keyAry
        updateFilterSetting()
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenApplyFilter)
    }
    
    @IBAction func onChangeGender(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            filterSetting["gender"] = "f"
        } else {
            filterSetting["gender"] = "m"
        }
        
        updateFilterSetting()
    }
    
    @IBAction func onKeySelectItem(sender: UIButton) {
        let inputCell = sender.superview?.superview as! KeyInputTableViewCell
        editingKeyIndex = -1
        inputCell.keyFld.resignFirstResponder()
    }
    
    @IBAction func onKeyDeleteItem(sender: UIButton) {
        keyAry.removeAtIndex(sender.tag)
        filterTbl.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        makeInputForEdtingKey()
        if keyAry.count > 0 {
            filterSetting["keywords"] = keyAry
        } else {
            filterSetting.removeValueForKey("keywords")
        }
        updateFilterSetting()
    }
    
    @IBAction func onButtonSelectItem(sender: UIButton) {
        if sender.tag == 0 {
            APIClient.sharedInstance.specialId = nil
            APIClient.sharedInstance.shouldRestart = true
            
            self.revealViewController().revealToggleAnimated(true)
        } else if sender.tag == 1 {
            Utils.sharedInstance.resetFilterSetting()
            filterSetting = Utils.sharedInstance.filterSetting
            keyAry = [String]()
            filterTbl.reloadData()
            updateFilterCount()
        }
        
        Utils.trackAdjustEvent(Utils.adjustEventTokenApplyFilter)
    }
    
    @IBAction func onNormalSelectItem(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "OverShownKey")
        self.revealViewController().revealToggleAnimated(true)
    }
    
    // MARK: - CategorySelectDelegate
    func categoryDidSelect(category: [String : AnyObject]!, subCategory: [[String : AnyObject]]!) {
        // print("category selected: " + category.description + "\n" + subCategory!.description)
        if category == nil {
            filterSetting.removeValueForKey("mainCategory")
            filterSetting.removeValueForKey("subCategories")
        } else {
            let idVal = category["id"] as? Int
            if idVal == nil || idVal < 0 {
                filterSetting.removeValueForKey("mainCategory")
                filterSetting.removeValueForKey("subCategories")
            } else {
                filterSetting["mainCategory"] = category
                if subCategory == nil || subCategory.count == 0 {
                    filterSetting.removeValueForKey("subCategories")
                } else {
                    let subId = subCategory[0]["id"] as? Int
                    if subId == nil || subId < 0 {
                        filterSetting.removeValueForKey("subCategories")
                    } else {
                        filterSetting["subCategories"] = subCategory
                    }
                }
            }
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - SizeSelectDelegate
    func sizeDidSelect(sizes: [[String : AnyObject]]!) {
        print("size selected: " + sizes.description)
        if sizes == nil {
            filterSetting.removeValueForKey("sizes")
        } else {
            let sizeName = sizes[0]["number"] as! String
            if sizeName == NSLocalizedString("All Sizes", comment: "") {
                filterSetting.removeValueForKey("sizes")
            } else {
                filterSetting["sizes"] = sizes
            }
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - RebateSelectDelegate
    func rebateDidSelect(rebate: [String : AnyObject]!) {
        print("rebate selected: " + rebate.description)
        if rebate == nil {
            filterSetting.removeValueForKey("rebate")
        } else {
            let idVal = rebate["id"] as! Int
            if idVal < 0 {
                filterSetting.removeValueForKey("rebate")
            } else {
                filterSetting["rebate"] = rebate
            }
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - PriceSelectDelegate
    func priceDidSelect(minPrice: Int, maxPrice: Int) {
        print("price selected: \(minPrice) - \(maxPrice)")
        filterSetting["min"] = minPrice
        filterSetting["max"] = maxPrice
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - ColorSelectDelegate
    func colorDidSelect(colors: [[String : AnyObject]]!) {
        print("color selected: " + colors.description)
        if colors == nil || colors.count == 0 {
            filterSetting.removeValueForKey("colors")
        } else {
            let idVal = colors[0]["id"] as! Int
            if idVal < 0 {
                filterSetting.removeValueForKey("colors")
            } else {
                filterSetting["colors"] = colors
            }
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - BrandSelectDelegate
    func brandsDidSelect(brands: [[String : AnyObject]]!) {
        print("brand selected: " + brands.description)
        if brands == nil || brands.count == 0 {
            filterSetting.removeValueForKey("brands")
        } else {
            filterSetting["brands"] = brands
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 2)], withRowAnimation: .None)
    }
    
    // MARK: - ShopSelectDelegate
    func shopsDidSelect(shops: [[String : AnyObject]]!) {
        print("shop selected: " + shops.description)
        if shops == nil || shops.count == 0 {
            filterSetting.removeValueForKey("shops")
        } else {
            filterSetting["shops"] = shops
        }
        
        updateFilterSetting()
        
        filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 6, inSection: 2)], withRowAnimation: .None)
    }
    
    func updateFilterSetting() {
        Utils.sharedInstance.filterSetting = filterSetting
        Utils.sharedInstance.saveFilterSetting()
        
        updateFilterCount()
    }
    
    func updateFilterCount() {
        APIClient.sharedInstance.getFilterCounts({ (filterCount: [String : AnyObject]) -> Void in
            self.allOfferCount = filterCount["allOffers"] as! Int
            self.specialCounts = filterCount["specials"] as! [[String: String]]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // self.filterTbl.reloadSections(NSIndexSet(index: 3), withRowAnimation: .None)
                self.filterTbl.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 3)], withRowAnimation: .None)
            })
            }, failure: { (error: NSError!) -> Void in
        })
    }

}
