//
//  SizeViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 31/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol SizeSelectDelegate {
    func sizeDidSelect(sizes: [[String: AnyObject]]!)
}

class SizeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: SizeSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var sizeTbl: UITableView!
    @IBOutlet weak var emptyTextViw: UITextView!
    var initialSizes: [[String: AnyObject]]!
    var sizeAry: [[String: AnyObject]]!
    let sizeSortTable = ["XXXS", "XXS", "XS", "S", "M", "L", "XL", "XXL", "XXXL", "4XL", "5XL"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backBtn.makeBackButton()
        
        let headerTxt = NSLocalizedString("No category selected", comment: "")
        let bodyTxt = NSLocalizedString("Before filtering by brands, please select at least one category", comment: "")
        let emptyTxt = headerTxt + "\n\n" + bodyTxt as NSString
        var emptyStr = NSMutableAttributedString(string: emptyTxt as String, attributes: [NSForegroundColorAttributeName: UIColor(white: 56/255.0, alpha: 1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 13)!])
        let headerRng = emptyTxt.rangeOfString(headerTxt)
        emptyStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(30), range: headerRng)
        emptyTextViw.attributedText = emptyStr
        
        let filterSetting = Utils.sharedInstance.filterSetting
        var isActive = false
        if let mainCategory = filterSetting["mainCategory"] as? [String: AnyObject] {
            isActive = true
        } else if let keywords = filterSetting["keywords"] as? [String] {
            isActive = true
        }
        
        if isActive {
            sizeTbl.alpha = 1.0
            emptyTextViw.alpha = 0.0
            sizeAry = [["number": NSLocalizedString("All Sizes", comment: ""), "amount": 0]]
            loadSizes()
        } else {
            sizeTbl.alpha = 0.0
            emptyTextViw.alpha = 1.0
            applyBtn.alpha = 0.0
            sizeAry = [[String: AnyObject]]()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSizes() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getSizes({ (sizeInfo: [String : AnyObject]) -> Void in
            self.sizeAry[0]["amount"] = sizeInfo["allSizes"] as! Int
            var rawSizes = sizeInfo["sizes"] as! [[String: AnyObject]]
            rawSizes.sort({ (obj1: [String: AnyObject], obj2: [String: AnyObject]) -> Bool in
                let size1 = obj1["number"] as! String
                let size2 = obj2["number"] as! String
                if let size1Val = self.getHalfValue(size1) {
                    if let size2Val = self.getHalfValue(size2) {
                        return size1Val < size2Val
                    }
                    return true
                }
                if let size2Val = self.getHalfValue(size2) {
                    return false
                }
                
                if let size1Priority = find(self.sizeSortTable, size1) {
                    if let size2Priority = find(self.sizeSortTable, size2) {
                        return size1Priority < size2Priority
                    }
                    return true
                }
                if let size2Priority = find(self.sizeSortTable, size2) {
                    return false
                }
                
                return self.getNumberValue(size1) < self.getNumberValue(size2)
            })
            self.sizeAry.extend(rawSizes)
            self.sizeTbl.reloadData()
            self.selectInitialSizes()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func getHalfValue(strVal: String) -> Float? {
        var str = strVal.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if let intVal = str.toInt() {
            return Float(intVal)
        }
        
        if str.hasSuffix("1/2") {
            let index: String.Index = advance(str.startIndex, count(str) - count("1/2"))
            str = str.substringToIndex(index)
            str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if let intVal = str.toInt() {
                return Float(intVal) + 0.5
            }
            return 0.5
        }
        
        return nil
    }
    
    func getNumberValue(str: String) -> Int {
        var numberStr = ""
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for scalar in str.unicodeScalars {
            if digits.longCharacterIsMember(scalar.value) {
                numberStr += String(scalar)
            }
        }
        
        if let numberVal = numberStr.toInt() {
            return numberVal
        }
        
        return LONG_MAX
    }
    
    func selectInitialSizes() {
        var indexes = [NSIndexPath]()
        if initialSizes != nil {
            for initialItem in initialSizes {
                let initialName = initialItem["number"] as! String
                for var i = 0; i < sizeAry.count; i++ {
                    let subSizeName = sizeAry[i]["number"] as! String
                    if subSizeName == initialName {
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
            self.sizeTbl.selectRowAtIndexPath(indexItem, animated: false, scrollPosition: .None)
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            if let selectedIndexes = sizeTbl.indexPathsForSelectedRows() as? [NSIndexPath] {
                var selectedItems = [[String: AnyObject]]()
                for aSize in selectedIndexes {
                    selectedItems.append(sizeAry[aSize.row])
                }
                delegate.sizeDidSelect(selectedItems)
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
        return sizeAry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sizeItem = sizeAry[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SizeCell") as! SizeTableViewCell
        cell.config(sizeItem, isAll: (indexPath.row == 0))
        
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
