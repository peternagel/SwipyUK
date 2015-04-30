//
//  CategoryViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 18/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol CategorySelectDelegate {
    func categoryDidSelect(category: [String: AnyObject]!, subCategory: [[String: AnyObject]]!)
}

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SubCategorySelectDelegate {
    
    var delegate: CategorySelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var categoryTbl: UITableView!
    var initialCategory: [String: AnyObject]!
    var initialSubCategories: [[String: AnyObject]]!
    var categoryAry: [[String: AnyObject]]!
    var subCategoryAry: [[String: AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Kategorien"
        self.navigationItem.hidesBackButton = true
        
        backBtn.makeBackButton()
        categoryAry = [["id": -1, "title": NSLocalizedString("All Categories", comment: ""), "amount": 0]]
        loadCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCategory() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getCategory({ (categoryInfo: [String : AnyObject]) -> Void in
            self.categoryAry[0]["amount"] = categoryInfo["allCategories"] as! Int
            self.categoryAry.extend(categoryInfo["categories"] as! [[String: AnyObject]])
            self.categoryTbl.reloadData()
            self.selectInitialCategory()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func selectInitialCategory() {
        var index = 0
        if initialCategory != nil {
            if let initialId = initialCategory["id"] as? Int {
                for var i = 0; i < categoryAry.count; i++ {
                    let aCategory = categoryAry[i]
                    if let categoryId = aCategory["id"] as? Int {
                        if categoryId == initialId {
                            index = i
                            break
                        }
                    }
                }
            }
        }
        self.categoryTbl.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: .None)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            if let selectedCategory = categoryTbl.indexPathForSelectedRow() {
                let categoryItem = categoryAry[selectedCategory.row]
                delegate.categoryDidSelect(categoryItem, subCategory: subCategoryAry)
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
        return categoryAry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let categoryItem = categoryAry[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell") as! CategoryTableViewCell
        cell.config(categoryItem, isAll: (indexPath.row == 0))
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 {
            let categoryItem = categoryAry[indexPath.row]
            let categoryId = categoryItem["id"] as! Int!
            let subCategoryCtlr = self.storyboard?.instantiateViewControllerWithIdentifier("SubCategoryView") as! SubCategoryViewController
            subCategoryCtlr.delegate = self
            subCategoryCtlr.mainCategory = categoryItem
            if initialCategory != nil {
                if let initialId = initialCategory["id"] as? Int {
                    if initialId == categoryId {
                        subCategoryCtlr.initialSubCategories = initialSubCategories
                    }
                }
            }
            self.navigationController?.pushViewController(subCategoryCtlr, animated: true)
        }
    }
    
    // MARK: - SubCategorySelectDelegate
    func subCategorysDidSelect(subCategorys: [[String : AnyObject]]!) {
        // println("sub category selected: " + subCategorys.description)
        subCategoryAry = subCategorys
        if delegate != nil {
            let selectedCategory = categoryTbl.indexPathForSelectedRow()!
            let categoryItem = categoryAry[selectedCategory.row]
            delegate.categoryDidSelect(categoryItem, subCategory: subCategoryAry)
        }
    }

}
