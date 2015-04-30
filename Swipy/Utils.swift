//
//  Utils.swift
//  Swipy
//
//  Created by Niklas Olsson on 27/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit
import CoreLocation

class Utils: NSObject, CLLocationManagerDelegate {
    
    var SW_PURPLE = UIColor(red: 206/255.0, green: 166/255.0, blue: 192/255.0, alpha: 1.0)
    var wishlist = [SWGood]()
    let kWishlist = "WishlistKey"
    var filterInfo = [String: AnyObject]()
    let kFilterInfo = "FilterInfoKey"
    var filterSetting = [String: AnyObject]()
    let kFilterSetting = "FilterSettingKey"
    var imageCache = [String: NSData]()
    let kImageCache = "ImageCacheKey"
    var emailAddress: String! = ""
    let kEmailAddress = "EmailAddressKey"
    // var documentInteractionController: UIDocumentInteractionController!
    let kDeepLinkItemNotification = "DeepLinkItemNotificationKey"
    let kDeepLinkSpecialNotification = "DeepLinkSpecialNotificationKey"
    let kDeepLinkFilterNotification = "DeepLinkFilterNotificationKey"
    var isMainViewLoaded = false
    var hud: MBProgressHUD!
    var hudAutoHide = false
    var hudCounter: Int = 0
    var trackingInfo = [String: AnyObject]()
    let kTrackingInfo = "TrackingInfoKey"
    
    var locationManager: CLLocationManager!
    var coordinate: CLLocationCoordinate2D!
    let kLocationLatitude = "LocationLatitudeKey"
    let kLocationLongitude = "LocationLongitudeKey"
    
    var currencyFormatter: NSNumberFormatter!
    
    class var sharedInstance: Utils {
        struct Static {
            static let instance: Utils = Utils()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        loadWishlist()
        loadFilterInfo()
        loadFilterSetting()
        loadEmailAddress()
        loadTracking()
        initLocation()
    }
    
    func saveWishlist() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(wishlist)
        userStore.setObject(encodedData, forKey: kWishlist)
        userStore.synchronize()
    }
    
    func loadWishlist() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if let archivedData = userStore.objectForKey(kWishlist) as? NSData {
            wishlist = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as! [SWGood]
        } else {
            resetWishlist()
        }
    }
    
    func insertWishitem(item: SWGood) {
        wishlist.insert(item, atIndex: 0)
        saveWishlist()
        
        for imageLink in item.images {
            let imageData = imageCache[imageLink]
            if imageData == nil {
                
            }
        }
    }
    
    func removeWishitemAtIndex(index: Int) {
        if 0 <= index && index < wishlist.count {
            let item = wishlist[index]
            SDImageCache.sharedImageCache().removeImageForKey(SDWebImageManager.sharedManager().cacheKeyForURL(NSURL(string: item.imageLink)))
            for itemLink in item.images {
                SDImageCache.sharedImageCache().removeImageForKey(SDWebImageManager.sharedManager().cacheKeyForURL(NSURL(string: itemLink)))
            }
            wishlist.removeAtIndex(index)
            saveWishlist()
        }
    }
    
    func resetWishlist() {
        wishlist = [SWGood]()
        saveWishlist()
    }
    
    func getWishlistParameters() -> [[String: AnyObject]] {
        var params = [[String: AnyObject]]()
        for item in wishlist {
            var itemParam = [String: AnyObject]()
            itemParam["title"] = item.title
            itemParam["image"] = item.imageLink
            itemParam["price"] = item.price
            itemParam["oldPrice"] = item.oldPrice
            itemParam["discount"] = item.discount
            itemParam["merchant"] = item.merchant
            itemParam["link"] = item.link
            params.append(itemParam)
        }
        
        return params
    }
    
    func saveFilterInfo() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(filterInfo)
        userStore.setObject(encodedData, forKey: kFilterInfo)
        userStore.synchronize()
    }
    
    func loadFilterInfo() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if let archivedData = userStore.objectForKey(kFilterInfo) as? NSData {
            filterInfo = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as! [String: AnyObject]
        } else {
            filterInfo = [String: AnyObject]()
            saveFilterInfo()
        }
    }
    
    func getCategoryFromFilter(categoryId: Int) -> [String: AnyObject]! {
        if let categories = filterInfo["categories"] as? [String: AnyObject] {
            let gender = filterSetting["gender"] as! String
            var categoryAry: [[String: AnyObject]]!
            if gender == "f" {
                categoryAry = categories["female"] as! [[String: AnyObject]]
            } else if gender == "m" {
                categoryAry = categories["male"] as! [[String: AnyObject]]
            }
            if categoryAry != nil {
                for categoryItem in categoryAry {
                    let itemId = categoryItem["id"] as! Int
                    if itemId == categoryId {
                        return categoryItem
                    }
                }
            }
        }
        
        return nil
    }
    
    func getColorFromFilter(colorId: Int) -> [String: AnyObject]! {
        if let colors = filterInfo["colors"] as? [[String: AnyObject]] {
            for colorItem in colors {
                let itemId = colorItem["id"] as! Int
                if itemId == colorId {
                    return colorItem
                }
            }
        }
        
        return nil
    }
    
    func saveFilterSetting() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(filterSetting)
        userStore.setObject(encodedData, forKey: kFilterSetting)
        userStore.synchronize()
    }
    
    func loadFilterSetting() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if let archivedData = userStore.objectForKey(kFilterSetting) as? NSData {
            filterSetting = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as! [String: AnyObject]
        } else {
            resetFilterSetting()
        }
    }
    
    func resetFilterSetting() {
        filterSetting = [String: AnyObject]()
        filterSetting["gender"] = "f"
        filterSetting["min"] = 0
        filterSetting["max"] = 0
        
        saveFilterSetting()
    }
    
    func saveImageCache() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(imageCache)
        userStore.setObject(encodedData, forKey: kImageCache)
        userStore.synchronize()
    }
    
    func loadImageCache() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if let archivedData = userStore.objectForKey(kImageCache) as? NSData {
            imageCache = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as! [String: NSData]
        } else {
            resetImageCache()
        }
    }
    
    func resetImageCache() {
        imageCache = [String: NSData]()
        saveImageCache()
    }
    
    func cacheImage(image: UIImage, key: String) {
        imageCache[key] = UIImageJPEGRepresentation(image, 0.8)
        saveImageCache()
    }
    
    func cachedImage(key: String) -> UIImage? {
        let imageData = imageCache[key]
        if imageData != nil {
            return UIImage(data: imageData!)
        }
        
        return nil
    }
    
    func removeCachedImage(key: String) {
        imageCache.removeValueForKey(key)
        saveImageCache()
    }
    
    func saveEmailAddress() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if emailAddress == nil {
            emailAddress = ""
        }
        userStore.setObject(emailAddress, forKey: kEmailAddress)
        userStore.synchronize()
    }
    
    func loadEmailAddress() {
        let userStore = NSUserDefaults.standardUserDefaults()
        emailAddress = userStore.stringForKey(kEmailAddress)
        if emailAddress == nil {
            emailAddress = ""
            userStore.setObject(emailAddress, forKey: kEmailAddress)
            userStore.synchronize()
        }
    }
    
    func saveTracking() {
        let userStore = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(trackingInfo)
        userStore.setObject(encodedData, forKey: kTrackingInfo)
        userStore.synchronize()
    }
    
    func loadTracking() {
        let userStore = NSUserDefaults.standardUserDefaults()
        if let archivedData = userStore.objectForKey(kTrackingInfo) as? NSData {
            trackingInfo = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as! [String: AnyObject]
        } else {
            resetTracking()
        }
    }
    
    func resetTracking() {
        trackingInfo = [String: AnyObject]()
        saveTracking()
    }
    
    func appendTracking(itemType: String, itemId: Int) {
        var idAry = trackingInfo[itemType] as! [Int]!
        if idAry == nil {
            idAry = [Int]()
        }
        idAry.append(itemId)
        trackingInfo[itemType] = idAry
        saveTracking()
        
        var totalCnt = 0
        for (type, ids) in trackingInfo {
            if let trackIds = ids as? [Int] {
                totalCnt += trackIds.count
            }
        }
        if totalCnt >= 10 {
            APIClient.sharedInstance.reporting({ () -> Void in
                self.resetTracking()
                }, failure: { (error: NSError!) -> Void in
            })
        }
    }
    
    func saveLocation() {
        if coordinate != nil {
            let userStore = NSUserDefaults.standardUserDefaults()
            userStore.setDouble(coordinate.latitude, forKey: kLocationLatitude)
            userStore.setDouble(coordinate.longitude, forKey: kLocationLongitude)
            userStore.synchronize()
        }
    }
    
    func loadLocation() {
        let userStore = NSUserDefaults.standardUserDefaults()
        coordinate = CLLocationCoordinate2DMake(userStore.doubleForKey(kLocationLatitude), userStore.doubleForKey(kLocationLongitude))
    }
    
    func initLocation() {
        loadLocation()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    class func canShareViaWhatsApp() -> Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "whatsapp://app")!)
    }
    
    class func shareLinkViaWhatsApp(shareLink: String!) {
        let whatsappLink = "whatsapp://send?text=" + shareLink.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        UIApplication.sharedApplication().openURL(NSURL(string: whatsappLink)!)
        /*
        let imageLink = NSURL(string: product.imageLink)
        let dummyImageViw = UIImageView()
        dummyImageViw.sd_setImageWithURL(imageLink, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
            if image != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let savePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/whatsAppTmp.wai")
                    UIImageJPEGRepresentation(image, 1.0).writeToFile(savePath, atomically: true)
                    self.documentInteractionController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: savePath)!)
                    self.documentInteractionController.UTI = "net.whatsapp.image"
                    self.documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: inView, animated: true)
                })
            } else {
                let shareLink = "http://swipy.it/" + product.itemId
                let whatsappLink = "whatsapp://send?text=" + shareLink.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                UIApplication.sharedApplication().openURL(NSURL(string: whatsappLink)!)
            }
        })*/
    }
    
    func handleUrl(url: NSURL) {
        if url.scheme == "swipy" {
            if let urlResource = url.resourceSpecifier {
                let urlComponents = NSURLComponents(string: urlResource)
                if let queryItems = urlComponents?.queryItems as! [NSURLQueryItem]? {
                    var filterParams = [String: [String]]()
                    var isProcessed = false
                    for item in queryItems {
                        if item.name == "item" {
                            if let itemId = item.value {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                                    while !self.isMainViewLoaded {
                                        sleep(1)
                                    }
                                    NSNotificationCenter.defaultCenter().postNotificationName(self.kDeepLinkItemNotification, object: self, userInfo: ["id": itemId])
                                })
                                isProcessed = true
                                break
                            }
                        } else if item.name == "special" {
                            if item.value != nil {
                                APIClient.sharedInstance.specialId = item.value?.toInt()
                                NSNotificationCenter.defaultCenter().postNotificationName(kDeepLinkSpecialNotification, object: self, userInfo: ["id": item.value!])
                                isProcessed = true
                                break
                            }
                        } else {
                            if item.value != nil {
                                var filterAry = filterParams[item.name] as [String]?
                                if filterAry == nil {
                                    filterAry = [String]()
                                }
                                filterAry?.append(item.value!)
                                filterParams[item.name] = filterAry
                            }
                        }
                    }
                    
                    if !isProcessed && filterParams.count > 0 {
                        updateFilterSetting(filterParams)
                        APIClient.sharedInstance.specialId = nil
                        NSNotificationCenter.defaultCenter().postNotificationName(kDeepLinkFilterNotification, object: self)
                    }
                }
            }
        }
    }
    
    func updateFilterSetting(params: [String: [String]]) {
        resetFilterSetting()
        
        if let gender = params["g"] {
            let firstGender = gender[0]
            if firstGender == "f" || firstGender == "m" {
                filterSetting["gender"] = firstGender
            }
        }
        
        if let category = params["c"] {
            if let categoryId = category[0].toInt() {
                if let categoryInfo = getCategoryFromFilter(categoryId) {
                    let id = categoryInfo["id"] as! Int
                    if id >= 0 {
                        let title = categoryInfo["title"] as! String
                        filterSetting["mainCategory"] = ["id": id, "title": title, "amount": 0]
                        
                        if let subCategory = params["s"] {
                            if let subCategoryInfo = categoryInfo["subCategories"] as? [[String: AnyObject]] {
                                var subCategoryAry = [[String: AnyObject]]()
                                for subItem in subCategoryInfo {
                                    let itemId = subItem["id"] as! Int
                                    if contains(subCategory, String(itemId)) {
                                        if itemId > 0 {
                                            subCategoryAry.append(["id": itemId, "title": subItem["title"] as! String, "amount": 0])
                                        }
                                    }
                                }
                                if subCategoryAry.count > 0 {
                                    filterSetting["subCategories"] = subCategoryAry
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let size = params["si"] {
            var sizeAry = [[String: AnyObject]]()
            for oneSize in size {
                sizeAry.append(["number": oneSize, "amount": 0])
            }
            if sizeAry.count > 0 {
                filterSetting["sizes"] = sizeAry
            }
        }
        
        if let rebate = params["r"] {
            if let rebateId = rebate[0].toInt() {
                if rebateId % 10 == 0 && 0 <= rebateId && rebateId <= 60 {
                    filterSetting["rebate"] = ["id": rebateId, "amount": 0]
                }
            }
        }
        
        if let priceMin = params["pmin"] {
            if let pmin = priceMin[0].toInt() {
                filterSetting["min"] = pmin
            }
        }
        if let priceMax = params["pmax"] {
            if let pmax = priceMax[0].toInt() {
                filterSetting["max"] = pmax
            }
        }
        
        if let color = params["co"] {
            var colorAry = [[String: AnyObject]]()
            for oneColor in color {
                if let colorId = oneColor.toInt() {
                    if var colorInfo = getColorFromFilter(colorId) {
                        colorInfo["amount"] = 0
                        colorAry.append(colorInfo)
                    }
                }
            }
            if colorAry.count > 0 {
                filterSetting["colors"] = colorAry
            }
        }
        
        if let brand = params["b"] {
            var brandAry = [[String: AnyObject]]()
            for oneBrand in brand {
                brandAry.append(["id": 0, "name": oneBrand, "amount": 0])
            }
            if brandAry.count > 0 {
                filterSetting["brands"] = brandAry
            }
        }
        
        if let shop = params["sh"] {
            var shopAry = [[String: AnyObject]]()
            for oneShop in shop {
                shopAry.append(["id": 0, "name": oneShop, "amount": 0])
            }
            if shopAry.count > 0 {
                filterSetting["shops"] = shopAry
            }
        }
        
        if let keyword = params["k"] {
            var countedKeyAry = [String]()
            if keyword.count <= 4 {
                countedKeyAry = keyword
            } else {
                for i in 0..<4 {
                    countedKeyAry.append(keyword[i])
                }
            }
            if countedKeyAry.count > 0 {
                filterSetting["keywords"] = countedKeyAry
            }
        }
        
        saveFilterSetting()
    }
    
    func showHUD(inView: UIView, autoHide: Bool = false) {
        if hud == nil {
            hud = MBProgressHUD(view: inView)
            hud.userInteractionEnabled = false
            hud.mode = .CustomView
            hud.customView = UIImageView(image: UIImage(named: "wish_icon"))
            hud.labelText = "Loading..."
            hud.color = UIColor.clearColor()
            hud.labelColor = UIColor.blackColor()
            hud.labelFont = UIFont(name: "HelveticaNeue-Thin", size: 20)
            hud.removeFromSuperViewOnHide = true
        }
        inView.addSubview(hud)
        hud.show(true)
        hudAutoHide = autoHide
        hudCounter = 0
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "animateHUD:", userInfo: nil, repeats: true)
    }
    
    func animateHUD(timer: NSTimer) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var shouldEnd = false
            if self.hudAutoHide {
                let after = timer.timeInterval * Double(self.hudCounter)
                if Int(floor(after)) >= 3 {
                    shouldEnd = true
                }
            }
            if self.hud.superview == nil {
                shouldEnd = true
            }
            
            if shouldEnd {
                self.hud.hide(true)
                self.hud.removeFromSuperview()
                timer.invalidate()
                return
            }
            
            let alphaVal = fabs(1 - CGFloat(self.hudCounter%10) / 5.0)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.hud.customView.alpha = alphaVal
            })
            self.hudCounter++
        })
    }
    
    func hideHUD() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if (error != nil) {
            println(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let locationAry = locations as? [CLLocation] {
            if let aLocation = locationAry.last {
                coordinate = aLocation.coordinate
                println("location: \(coordinate.latitude), \(coordinate.longitude)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .NotDetermined && status != .Restricted && status != .Denied {
            locationManager.startUpdatingLocation()
        }
    }
    
    func currencyStringFor(price: AnyObject) -> String {
        if currencyFormatter == nil {
            currencyFormatter = NSNumberFormatter()
            currencyFormatter.numberStyle = .CurrencyStyle
            // currencyFormatter.locale = NSLocale.currentLocale()
        }
        
        var priceNumber: NSNumber!
        if let intPrice = price as? Int {
            priceNumber = NSNumber(integer: intPrice)
        } else if let floatPrice = price as? Float {
            priceNumber = NSDecimalNumber(float: floatPrice)
        } else if let doublePrice = price as? Double {
            priceNumber = NSDecimalNumber(double: doublePrice)
        }
        
        if let priceString = currencyFormatter.stringFromNumber(priceNumber) {
            return priceString
        } else {
            return ""
        }
    }
    
    
    // MARK: - Class Functions
    
    class func toString(obj: AnyObject!) -> String {
        if obj != nil {
            return String(format: "%@", obj as! NSObject)
        }
        
        return ""
    }
    
    class func toString(obj: AnyObject!, key: String!) -> String {
        if let dic = obj as? [String: AnyObject] {
            return Utils.toString(dic[key])
        }
        
        return ""
    }
    
    class func toInt(obj: AnyObject!) -> Int {
        return Utils.toString(obj).toInt()!
    }
    
    class func toInt(obj: AnyObject!, key: String!) -> Int {
        if let dic = obj as? [String: AnyObject] {
            return Utils.toInt(dic[key])
        }
        
        return 0
    }
    
    class func toFloat(obj: AnyObject!) -> Float {
        return (Utils.toString(obj) as NSString).floatValue
    }
    
    class func toFloat(obj: AnyObject!, key: String!) -> Float {
        if let dic = obj as? [String: AnyObject] {
            return Utils.toFloat(dic[key])
        }
        
        return 0.0
    }
    
    class func toBool(obj: AnyObject!) -> Bool {
        if let boolValue = obj as? Bool {
            return boolValue
        }
        return false
    }
    
    class func toBool(obj: AnyObject!, key: String!) -> Bool {
        if let dic = obj as? [String: AnyObject] {
            return Utils.toBool(dic[key])
        }
        
        return false
    }
    
    class func toArray(obj: AnyObject!, key: String!) -> [AnyObject] {
        if let dic = obj as? [String: AnyObject] {
            if let ary = dic[key] as? [AnyObject] {
                return ary
            }
        }
        
        return [AnyObject]()
    }
    
    class func toDictionary(obj: AnyObject!, key: String!) -> [String: AnyObject] {
        if let dic = obj as? [String: AnyObject] {
            if let dic = dic[key] as? [String: AnyObject] {
                return dic
            }
        }
        
        return [String: AnyObject]()
    }
    
}

extension UIApplication {
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as! String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}

extension UIButton {
    
    func makeBackButton() {
        let iconTxt = String.fontAwesomeIconWithName(FontAwesome.CaretLeft)
        let titleTxt = iconTxt + " " + NSLocalizedString("Back", comment: "") as NSString
        let titleStr = NSMutableAttributedString(string: titleTxt as String)
        titleStr.addAttribute(NSFontAttributeName, value: UIFont.fontAwesomeOfSize(16), range: titleTxt.rangeOfString(iconTxt))
        self.setAttributedTitle(titleStr, forState: .Normal)
    }
    
}

extension UIViewController {
    
    func pushModalViewController(viewControllerToPresent: UIViewController) {
        var transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        
        presentViewController(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func popModalControllerAnimated() {
        var transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
    
}
