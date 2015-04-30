//
//  ShopViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 21/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol ShopSelectDelegate {
    func shopsDidSelect(shops: [[String: AnyObject]]!)
}

class ShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: ShopSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shopTbl: UITableView!
    var allShopInfo: [String: AnyObject]!
    var initialShops: [[String: AnyObject]]!
    var topShopAry = [[String: AnyObject]]()
    var shopAry = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Shops"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        allShopInfo = ["name": "In allen Shops suchen", "amount": 0]
        loadShopes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadShopes() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getShops({ (shopInfo: [String : AnyObject]) -> Void in
            self.allShopInfo["amount"] = shopInfo["allShops"] as! Int
            self.shopAry = shopInfo["shops"] as! [[String: AnyObject]]
            self.getTopShopInfo()
            self.shopTbl.reloadData()
            self.selectInitialShops()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func selectInitialShops() {
        var indexes = [NSIndexPath]()
        if initialShops != nil {
            for initialItem in initialShops {
                let initialName = initialItem["name"] as! String
                for var i = 0; i < topShopAry.count; i++ {
                    let shopName = topShopAry[i]["name"] as! String
                    if shopName == initialName {
                        indexes.append(NSIndexPath(forRow: 1+i, inSection: 1))
                        break
                    }
                }
                for var i = 0; i < shopAry.count; i++ {
                    let shopName = shopAry[i]["name"] as! String
                    if shopName == initialName {
                        indexes.append(NSIndexPath(forRow: 1+i, inSection: 2))
                        break
                    }
                }
            }
        }
        if indexes.count == 0 {
            indexes.append(NSIndexPath(forRow: 0, inSection: 0))
        }
        for indexItem in indexes {
            self.shopTbl.selectRowAtIndexPath(indexItem, animated: false, scrollPosition: .None)
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            if let selectedIndexes = shopTbl.indexPathsForSelectedRows() as? [NSIndexPath] {
                var selectedItems = [[String: AnyObject]]()
                for aShopIndex in selectedIndexes {
                    if aShopIndex.section == 2 {
                        selectedItems.append(shopAry[aShopIndex.row - 1])
                    }
                }
                delegate.shopsDidSelect(selectedItems)
            }
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getTopShopInfo() {
        let filter = Utils.sharedInstance.filterInfo
        let topShops = filter["topShops"] as! [String]
        topShopAry = [[String: AnyObject]]()
        for topItem in topShops {
            for aShop in shopAry {
                let shopName = aShop["name"] as! String
                if shopName == topItem {
                    let shopAmount = aShop["amount"] as! Int
                    topShopAry.append(["name": shopName, "amount": shopAmount])
                    break
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1 + topShopAry.count
        } else if section == 2 {
            return 1 + shopAry.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ShopCell") as! ShopTableViewCell
            cell.config(allShopInfo, isAll: true)
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! UITableViewCell
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
                cell.textLabel?.text = "Top Shops"
                
                return cell
            } else {
                let shopItem = topShopAry[indexPath.row - 1]
                var cell = tableView.dequeueReusableCellWithIdentifier("ShopCell") as! ShopTableViewCell
                cell.config(shopItem, isAll: false)
                
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! UITableViewCell
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
                cell.textLabel?.text = NSLocalizedString("All Shops", comment: "")
                
                return cell
            } else {
                let shopItem = shopAry[indexPath.row - 1]
                var cell = tableView.dequeueReusableCellWithIdentifier("ShopCell") as! ShopTableViewCell
                cell.config(shopItem, isAll: false)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 0 && indexPath.row == 0 {
            return
        }
        
        let selectedIndexes = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        if indexPath.section == 0 {
            for anItem in selectedIndexes {
                if anItem.section != 0 {
                    tableView.deselectRowAtIndexPath(anItem, animated: true)
                }
            }
        } else {
            for anItem in selectedIndexes {
                if anItem.section == 0 {
                    tableView.deselectRowAtIndexPath(anItem, animated: true)
                    break
                }
            }
        }
        
        // select the matching cell
        if indexPath.section == 1 {
            let topShopInfo = topShopAry[indexPath.row - 1]
            let topShopName = topShopInfo["name"] as! String
            for var i = 0; i < shopAry.count; i++ {
                let shopName = shopAry[i]["name"] as! String
                if shopName == topShopName {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: 1+i, inSection: 2), animated: true, scrollPosition: .None)
                    break
                }
            }
        } else if indexPath.section == 2 {
            let shopInfo = shopAry[indexPath.row - 1]
            let shopName = shopInfo["name"] as! String
            for var i = 0; i < topShopAry.count; i++ {
                let topShopName = topShopAry[i]["name"] as! String
                if topShopName == shopName {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: 1+i, inSection: 1), animated: true, scrollPosition: .None)
                    break
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 0 && indexPath.row == 0 {
            return
        }
        
        let selectedIndexes = tableView.indexPathsForSelectedRows()
        if selectedIndexes == nil || selectedIndexes?.count == 0 {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
        }
        
        // deselect the matching cell
        if indexPath.section == 1 {
            let topShopInfo = topShopAry[indexPath.row - 1]
            let topShopName = topShopInfo["name"] as! String
            for var i = 0; i < shopAry.count; i++ {
                let shopName = shopAry[i]["name"] as! String
                if shopName == topShopName {
                    tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1+i, inSection: 2), animated: true)
                    break
                }
            }
        } else if indexPath.section == 2 {
            let shopInfo = shopAry[indexPath.row - 1]
            let shopName = shopInfo["name"] as! String
            for var i = 0; i < topShopAry.count; i++ {
                let topShopName = topShopAry[i]["name"] as! String
                if topShopName == shopName {
                    tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1+i, inSection: 1), animated: true)
                    break
                }
            }
        }
    }

}
