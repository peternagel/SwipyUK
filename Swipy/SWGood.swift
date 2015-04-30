//
//  SWGood.swift
//  Swipy
//
//  Created by Niklas Olsson on 27/02/15.
//  Copyright (c) 2015 niklasolsson. All rights reserved.
//

import UIKit

class SWItem: NSObject {
    var itemId = 0
    var link = ""
    var imageLink = ""
    
    override init() {
        super.init()
    }
    
    init(response: AnyObject!) {
        super.init()
        
        itemId = Utils.toInt(response, key: "id")
        link = Utils.toString(response, key: "link")
        imageLink = Utils.toString(response, key: "image")
    }
}

class SWGood: SWItem, NSCoding {
    var deliveryTime = ""
    var goodDesc = ""
    var discount: Float = 0.0
    var discounted = false
    var discountPercent = 0
    var gender = 0
    var mainImage: NSData!
    var images = [String]()
    var likes = 0
    var merchant = ""
    var merchantObj = [String: String]()
    var oldPrice: Float = 0.0
    var price: Float = 0.0
    var sizes = [String]()
    var colors = [String]()
    var title = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        deliveryTime = aDecoder.decodeObjectForKey("deliveryTime") as! String
        goodDesc = aDecoder.decodeObjectForKey("description") as! String
        discount = aDecoder.decodeFloatForKey("discount")
        discounted = aDecoder.decodeBoolForKey("discounted")
        discountPercent = aDecoder.decodeIntegerForKey("discountedPercentage")
        gender = aDecoder.decodeIntegerForKey("gender")
        itemId = aDecoder.decodeIntegerForKey("id")
        imageLink = aDecoder.decodeObjectForKey("image") as! String
        if let savedMainImage = aDecoder.decodeObjectForKey("mainImage") as? NSData {
            mainImage = savedMainImage
        }
        images = aDecoder.decodeObjectForKey("images") as! [String]
        likes = aDecoder.decodeIntegerForKey("likes")
        link = aDecoder.decodeObjectForKey("link") as! String
        merchant = aDecoder.decodeObjectForKey("merchant") as! String
        merchantObj = aDecoder.decodeObjectForKey("merchantObj") as! [String: String]
        oldPrice = aDecoder.decodeFloatForKey("oldPrice")
        price = aDecoder.decodeFloatForKey("price")
        sizes = aDecoder.decodeObjectForKey("sizes") as! [String]
        colors = aDecoder.decodeObjectForKey("colors") as! [String]
        title = aDecoder.decodeObjectForKey("title") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(deliveryTime, forKey: "deliveryTime")
        aCoder.encodeObject(goodDesc, forKey: "description")
        aCoder.encodeFloat(discount, forKey: "discount")
        aCoder.encodeBool(discounted, forKey: "discounted")
        aCoder.encodeInteger(discountPercent, forKey: "discountedPercentage")
        aCoder.encodeInteger(gender, forKey: "gender")
        aCoder.encodeInteger(itemId, forKey: "id")
        aCoder.encodeObject(imageLink, forKey: "image")
        aCoder.encodeObject(mainImage, forKey: "mainImage")
        aCoder.encodeObject(images, forKey: "images")
        aCoder.encodeInteger(likes, forKey: "likes")
        aCoder.encodeObject(link, forKey: "link")
        aCoder.encodeObject(merchant, forKey: "merchant")
        aCoder.encodeObject(merchantObj, forKey: "merchantObj")
        aCoder.encodeFloat(oldPrice, forKey: "oldPrice")
        aCoder.encodeFloat(price, forKey: "price")
        aCoder.encodeObject(sizes, forKey: "sizes")
        aCoder.encodeObject(colors, forKey: "colors")
        aCoder.encodeObject(title, forKey: "title")
    }
    
    override init(response: AnyObject!) {
        super.init(response: response)
        
        deliveryTime = Utils.toString(response, key: "deliveryTime")
        goodDesc = Utils.toString(response, key: "description")
        discount = Utils.toFloat(response, key: "discount")
        discounted = Utils.toBool(response, key: "discounted")
        discountPercent = Utils.toInt(response, key: "discountedPercentage")
        gender = Utils.toInt(response, key: "gender")
        images = Utils.toArray(response, key: "images") as! [String]
        likes = Utils.toInt(response, key: "likes")
        merchant = Utils.toString(response, key: "merchant")
        merchantObj = Utils.toDictionary(response, key: "merchantObj") as! [String: String]
        oldPrice = Utils.toFloat(response, key: "oldPrice")
        price = Utils.toFloat(response, key: "price")
        sizes = Utils.toArray(response, key: "sizes") as! [String]
        colors = Utils.toArray(response, key: "colors") as! [String]
        title = Utils.toString(response, key: "title")
    }
}


class SWAdvertisement: SWItem {
    var adId = 0
    var adjustEvent = ""
    var name = ""
    
    override init(response: AnyObject!) {
        super.init(response: response)
        
        adId = Utils.toInt(response, key: "adId")
        adjustEvent = Utils.toString(response, key: "adjustEvent")
        name = Utils.toString(response, key: "name")
    }
}
