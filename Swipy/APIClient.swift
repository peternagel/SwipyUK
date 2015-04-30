//
//  APIClient.swift
//  Swipy
//
//  Created by Niklas Olsson on 27/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    // let SERVER_URL = "http://87.230.85.253/"
    let SERVER_URL = "http://swipyapp.uk/"
    var specialId: Int!
    var shouldRestart = false
    var networkStatus = "Unknown"
    
    class var sharedInstance: APIClient {
        struct Static {
            static let instance: APIClient = APIClient()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .Unknown:          self.networkStatus = "Unknown"
            case .NotReachable:     self.networkStatus = "Not Connected"
            case .ReachableViaWWAN: self.networkStatus = "WWAN"
            case .ReachableViaWiFi: self.networkStatus = "WiFi"
            }
        }
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
    }
    
    func getUserInfo() -> [String: AnyObject] {
        var userInfo = [String: AnyObject]()
        userInfo["appVersion"] = UIApplication.appVersion()
        // userInfo["id"] = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        let userStore = NSUserDefaults.standardUserDefaults()
        userInfo["id"] = userStore.objectForKey("ApplicationUniqueIdentifier")
        userInfo["connection"] = networkStatus
        userInfo["model"] = GBDeviceInfo.deviceInfo().modelString
        userInfo["platform"] = "iOS"
        userInfo["platformVersion"] = UIDevice.currentDevice().systemVersion
        if let locationCoordinate = Utils.sharedInstance.coordinate {
            userInfo["latitude"] = locationCoordinate.latitude
            userInfo["longitude"] = locationCoordinate.longitude
        }
        
        return userInfo
    }
    
    func getSpecialGoods(success: ([SWItem]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "specials"
        var params: [String: AnyObject] = ["id": specialId]
        params["user"] = getUserInfo()
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                var goodAry = [SWItem]()
                for goodItem in responseObject as! [AnyObject] {
                    let item = SWItem(response: goodItem)
                    if item.itemId >= 0 {
                        goodAry.append(SWGood(response: goodItem))
                    } else {
                        goodAry.append(SWAdvertisement(response: goodItem))
                    }
                }
                success(goodAry)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func isContainItem(container: [String]!, item: String!) -> Bool {
        if container == nil || item == nil {
            return false
        }
        
        return contains(container, item)
    }
    
    func getFilterParams(excepts: [String]!) -> [String: AnyObject] {
        let filterSetting = Utils.sharedInstance.filterSetting
        var filterParams = [String: AnyObject]()
        
        if !isContainItem(excepts, item: "gender") {
            if filterSetting["gender"] != nil {
                filterParams["gender"] = filterSetting["gender"]
            }
        }
        
        if !isContainItem(excepts, item: "keywords") {
            if filterSetting["keywords"] != nil {
                filterParams["keywords"] = filterSetting["keywords"]
            }
        }
        
        if !isContainItem(excepts, item: "mainCategory") {
            if let mainCategory = filterSetting["mainCategory"] as? [String: AnyObject] {
                filterParams["mainCategory"] = mainCategory["id"]
            }
        }
        
        if !isContainItem(excepts, item: "subCategories") {
            if let subCategories = filterSetting["subCategories"] as? [[String: AnyObject]] {
                var subItems = [Int]()
                for subItem in subCategories {
                    subItems.append(subItem["id"] as! Int)
                }
                filterParams["subCategories"] = subItems
            }
        }
        
        if !isContainItem(excepts, item: "sizes") {
            if let sizes = filterSetting["sizes"] as? [[String: AnyObject]] {
                var sizeItems = [String]()
                for sizeItem in sizes {
                    sizeItems.append(sizeItem["number"] as! String)
                }
                filterParams["sizes"] = sizeItems
            }
        }
        
        if !isContainItem(excepts, item: "rebate") {
            if let rebate = filterSetting["rebate"] as? [String: AnyObject] {
                filterParams["rebateV"] = rebate["id"]
            }
        }
        
        if !isContainItem(excepts, item: "min") {
            if filterSetting["min"] != nil {
                filterParams["min"] = filterSetting["min"]
            }
        }
        if !isContainItem(excepts, item: "max") {
            if filterSetting["max"] != nil {
                filterParams["max"] = filterSetting["max"]
            }
        }
        
        if !isContainItem(excepts, item: "colors") {
            if let colors = filterSetting["colors"] as? [[String: AnyObject]] {
                var colorItems = [Int]()
                for colorItem in colors {
                    colorItems.append(colorItem["id"] as! Int)
                }
                filterParams["colors"] = colorItems
            }
        }
        
        if !isContainItem(excepts, item: "brands") {
            if let brands = filterSetting["brands"] as? [[String: AnyObject]] {
                var brandItems = [String]()
                for brandItem in brands {
                    brandItems.append(brandItem["name"] as! String)
                }
                filterParams["brands"] = brandItems
            }
        }
        
        if !isContainItem(excepts, item: "shops") {
            if let shops = filterSetting["shops"] as? [[String: AnyObject]] {
                var shopItems = [String]()
                for shopItem in shops {
                    shopItems.append(shopItem["name"] as! String)
                }
                filterParams["shops"] = shopItems
            }
        }
        
        if !isContainItem(excepts, item: "user") {
            filterParams["user"] = getUserInfo()
        }
        
        return filterParams
    }
    
    func getGoods(success: ([SWItem]) -> Void, failure: (NSError!) -> Void) {
        if Utils.sharedInstance.trackingInfo.count > 0 {
            reporting({ () -> Void in
                Utils.sharedInstance.resetTracking()
                self.getGoodsRequest(success, failure: failure)
                }, failure: { (error: NSError!) -> Void in
                    self.getGoodsRequest(success, failure: failure)
            })
        } else {
            self.getGoodsRequest(success, failure: failure)
        }
    }
    
    func getGoodsRequest(success: ([SWItem]) -> Void, failure: (NSError!) -> Void) {
        if self.specialId != nil {
            self.getSpecialGoods(success, failure: failure)
        } else {
            self.getOfferGoods(success, failure: failure)
        }
    }
    
    func getOfferGoods(success: ([SWItem]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "offers/v2.0"
        var params = getFilterParams(nil)
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                var goodAry = [SWItem]()
                for goodItem in responseObject as! [AnyObject] {
                    let item = SWItem(response: goodItem)
                    if item.itemId >= 0 {
                        goodAry.append(SWGood(response: goodItem))
                    } else {
                        goodAry.append(SWAdvertisement(response: goodItem))
                    }
                }
                success(goodAry)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getFilter(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter"
        manager.POST(url, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getCategory(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/categories/v1.0"
        let params = getFilterParams(["mainCategory", "subCategories"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getSubCategory(mainCategoryId: Int, success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/subcategories/v1.0"
        var params = getFilterParams(["mainCategory", "subCategories"])
        params["mainCategory"] = mainCategoryId
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            // println("JSON: " + responseObject.description)
            
            let filterInfo = responseObject as! [String: AnyObject]
            success(filterInfo)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            failure(error)
        }
    }
    
    func getSizes(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/sizes/v1.0"
        let params = getFilterParams(["sizes"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getRebate(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/rebates/v1.0"
        let params = getFilterParams(["rebate"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getPrices(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/prices/v1.0"
        let params = getFilterParams(["min", "max"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getColors(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/colors/v1.0"
        let params = getFilterParams(["colors"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getBrands(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/brands/v1.0"
        let params = getFilterParams(["brands"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getShops(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/shops/v1.0"
        let params = getFilterParams(["shops"])
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func getFilterCounts(success: ([String: AnyObject]) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "filter/v1.0"
        let params = getFilterParams(nil)
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                println("JSON: " + responseObject.description)
                
                let filterInfo = responseObject as! [String: AnyObject]
                success(filterInfo)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func sendWishlist(success: () -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "sendwishlist"
        let email = Utils.sharedInstance.emailAddress
        let wishlist = Utils.sharedInstance.getWishlistParameters()
        let userInfo = getUserInfo()
        let params = ["email": email, "wishlist": wishlist, "user": userInfo]
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                success()
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("fail: " + error.description)
                failure(error)
        })
    }
    
    func getGoodForId(id: String, success: (SWGood!) -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "angebote/" + id
        println("url: " + url + "(nil)")
        
        manager.POST(url, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                // println("JSON: " + responseObject.description)
                let item = SWGood(response: responseObject)
                success(item)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                failure(error)
        })
    }
    
    func reporting(success: () -> Void, failure: (NSError!) -> Void) {
        let manager = AFHTTPRequestOperationManager()
        let url = SERVER_URL + "reporting"
        var params = Utils.sharedInstance.trackingInfo
        // params["id"] = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        let userStore = NSUserDefaults.standardUserDefaults()
        params["id"] = userStore.objectForKey("ApplicationUniqueIdentifier")
        println("url: " + url + "(" + params.description + ")")
        
        manager.POST(url, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                success()
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("fail: " + error.description)
                failure(error)
        })
    }
    
}
