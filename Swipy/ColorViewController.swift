//
//  ColorViewController.swift
//  Swipy
//
//  Created by Niklas Olsson on 19/03/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

protocol ColorSelectDelegate {
    func colorDidSelect(colors: [[String: AnyObject]]!)
}

class ColorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var delegate: ColorSelectDelegate!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var colorCollect: UICollectionView!
    var initialColors: [[String: AnyObject]]!
    var colorAry: [[String: AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Farben"
        self.navigationItem.hidesBackButton = true
        backBtn.makeBackButton()
        
        colorCollect.allowsMultipleSelection = true
        
        colorAry = [["id": -1, "hexValue": "ffffff", "name": NSLocalizedString("All", comment: ""), "amount": 0]]
        loadColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadColors() {
        // Utils.sharedInstance.showHUD(self.view)
        APIClient.sharedInstance.getColors({ (colorInfo: [String : AnyObject]) -> Void in
            self.colorAry[0]["amount"] = colorInfo["allColors"] as! Int
            let colors = colorInfo["colors"] as! [[String: AnyObject]]
            for aColor in colors {
                let colorName = aColor["name"] as! String
                if colorName != "Ignorieren" {
                    self.colorAry.append(aColor)
                }
            }
            self.colorCollect.reloadData()
            self.selectInitialColors()
            // Utils.sharedInstance.hideHUD()
            }, failure: { (error: NSError!) -> Void in
                // Utils.sharedInstance.hideHUD()
        })
    }
    
    func selectInitialColors() {
        var indexes = [NSIndexPath]()
        if initialColors != nil {
            for initialItem in initialColors {
                let initialId = initialItem["id"] as! Int
                for var i = 0; i < colorAry.count; i++ {
                    let subColorId = colorAry[i]["id"] as! Int
                    if subColorId == initialId {
                        indexes.append(NSIndexPath(forItem: i, inSection: 0))
                        break
                    }
                }
            }
        }
        if indexes.count == 0 {
            indexes.append(NSIndexPath(forItem: 0, inSection: 0))
        }
        for indexItem in indexes {
            self.colorCollect.selectItemAtIndexPath(indexItem, animated: false, scrollPosition: .None)
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onApply(sender: AnyObject) {
        if delegate != nil {
            if let selectedIndexes = colorCollect.indexPathsForSelectedItems() as? [NSIndexPath] {
                var selectedItems = [[String: AnyObject]]()
                for aColor in selectedIndexes {
                    selectedItems.append(colorAry[aColor.item])
                }
                delegate.colorDidSelect(selectedItems)
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorAry.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let colorItem = colorAry[indexPath.item]
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCell", forIndexPath: indexPath) as! ColorCollectionViewCell
        cell.config(colorItem)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexes = collectionView.indexPathsForSelectedItems() as! [NSIndexPath]
        if indexPath.item == 0 {
            for anIndex in selectedIndexes {
                if anIndex.item > 0 {
                    collectionView.deselectItemAtIndexPath(anIndex, animated: true)
                }
            }
        } else {
            for anIndex in selectedIndexes {
                if anIndex.item == 0 {
                    collectionView.deselectItemAtIndexPath(anIndex, animated: true)
                    break
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let selectedIndexes = collectionView.indexPathsForSelectedItems() as! [NSIndexPath]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ColorCollectionViewCell
        if contains(selectedIndexes, indexPath) {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            if selectedIndexes.count <= 1 {
                collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: true, scrollPosition: .None)
            }
            return false
        } else {
            return true
        }
    }

}
