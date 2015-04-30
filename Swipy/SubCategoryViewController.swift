//
//  SubCategoryViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol SubCategorySelectDelegate {
    func subCategorysDidSelect(subCategorys: [[String: AnyObject]]!)
}

class SubCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: SubCategorySelectDelegate!
    var mainCategory: [String: AnyObject]!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var subCategoryTbl: UITableView!
    var initialSubCategories: [[String: AnyObject]]!
    var subCategoryAry: [[String: AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Sub Kategorien"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        subCategoryAry = [["id": -1, "title": NSLocalizedString("All", comment: ""), "amount": 0]]
        loadSubCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSubCategory() {
        // Utils.sharedInstance.showHUD(self.view)
        let mainId = mainCategory["id"] as! Int
        APIClient.sharedInstance.getSubCategory(mainId, success: { (subCategoryInfo: [String : AnyObject]) -> Void in
            self.subCategoryAry.extend(subCategoryInfo["subCategories"] as! [[String: AnyObject]])
            self.subCategoryTbl.reloadData()
            self.selectInitialSubCategory()
            // Utils.sharedInstance.hideHUD()
            }) { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        }
    }
    
    func selectInitialSubCategory() {
        var indexes = [NSIndexPath]()
        if initialSubCategories != nil {
            for initialItem in initialSubCategories {
                let initialId = initialItem["id"] as! Int
                for var i = 0; i < subCategoryAry.count; i++ {
                    let subCategoryId = subCategoryAry[i]["id"] as! Int
                    if subCategoryId == initialId {
                        indexes.append(NSIndexPath(forRow: i, inSection: 0))
                        break
                    }
                }
            }
        }
        if indexes.count == 0 {
            indexes.append(NSIndexPath(forRow: 0, inSection: 0))
        }
        for indexItem in indexes {
            self.subCategoryTbl.selectRowAtIndexPath(indexItem, animated: false, scrollPosition: .None)
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            let selectedIndexes = subCategoryTbl.indexPathsForSelectedRows() as! [NSIndexPath]
            var selectedItems = [[String: AnyObject]]()
            for aCat in selectedIndexes {
                selectedItems.append(subCategoryAry[aCat.row])
            }
            delegate.subCategorysDidSelect(selectedItems)
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
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
        return subCategoryAry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subCategoryItem = subCategoryAry[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SubCategoryCell") as! SubCategoryTableViewCell
        cell.config(subCategoryItem, isAll: (indexPath.row == 0))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexes = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        if indexPath.row == 0 {
            for anItem in selectedIndexes {
                if anItem.row != 0 {
                    tableView.deselectRowAtIndexPath(anItem, animated: true)
                }
            }
        } else {
            for anItem in selectedIndexes {
                if anItem.row == 0 {
                    tableView.deselectRowAtIndexPath(anItem, animated: true)
                    break
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexes = tableView.indexPathsForSelectedRows()
        if selectedIndexes == nil || selectedIndexes?.count == 0 {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
        }
    }

}
