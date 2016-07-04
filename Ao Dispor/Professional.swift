//
//  Professional.swift
//  Ao Dispor
//
//  Created by André Lamelas on 16/05/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import Foundation
import ObjectMapper
import Pantry
import CoreSpotlight
import MobileCoreServices
import Haneke

class Professional: Mappable, Storable, Equatable {
    var name:String?
    var title:String?
    var rate:String?
    var currency:String?
    var avatar:String?
    var description:String?
    var type:String?
    var string_id:String?
    var location:String?
    var phone:String?

    var avatarURL:String? {
        get {
            return avatar?.stringByReplacingOccurrencesOfString("regular", withString: "original")
        }
    }
    var cleanTitle:String? {
        get {
            return title?.stringByReplacingOccurrencesOfString("<highlight>", withString: "").stringByReplacingOccurrencesOfString("</highlight>", withString: "")
        }
    }

    // MARK: JSON
    required init?(_ map: Map) { }

    func mapping(map: Map) {
        name <- map["full_name"]
        title <- map["title"]
        rate <- map["rate"]
        currency <- map["currency"]
        avatar <- map["avatar_url"]
        description <- map["description"]
        type <- map["type"]
        string_id <- map["string_id"]
        location <- map["location"]
        phone <- map["phone"]
    }

    required init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.title = warehouse.get("title") ?? "default"
        self.rate = warehouse.get("rate") ?? "default"
        self.currency = warehouse.get("currency") ?? "default"
        self.avatar = warehouse.get("avatarURL") ?? "default"
        self.description = warehouse.get("description") ?? "default"
        self.type = warehouse.get("type") ?? "default"
        self.string_id = warehouse.get("string_id") ?? "default"
        self.location = warehouse.get("location") ?? "default"
        self.phone = warehouse.get("phone") ?? "default"
    }

    func toDictionary() -> [String : AnyObject] {
        var ret = [String:AnyObject]()
        ret["name"] = self.name
        ret["title"] = self.title
        ret["rate"] = self.rate
        ret["currency"] = self.currency
        ret["avatarURL"] = self.avatarURL
        ret["description"] = self.description
        ret["type"] = self.type
        ret["string_id"] = self.string_id
        ret["location"] = self.location
        ret["phone"] = self.phone
        return ret
    }

    // MARK: Spotlight
    static let domainIdentifier = "pt.aodispor.Ao-Dispor.professional"

    static func searchableItems(professionals:[Professional]) -> [CSSearchableItem] {
        var searchableItems = [CSSearchableItem]()
        professionals.forEach { (professional) in
            searchableItems.append(professional.searchableItem)
        }
        return searchableItems
    }

    var userActivityUserInfo: [NSObject: AnyObject] {
        return ["id": string_id!]
    }

    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: Professional.domainIdentifier)
        activity.title = self.name
        activity.userInfo = userActivityUserInfo
        activity.contentAttributeSet = attributeSet
        var keywords = self.cleanTitle!.componentsSeparatedByString(" ")
        keywords.append(self.location!)
        keywords.append("Ao Dispor")
        activity.keywords = Set(keywords)
        return activity
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = self.cleanTitle
        attributeSet.contentDescription = "\(self.location!)"
        if self.phone != nil {
            attributeSet.phoneNumbers = [self.phone!]
            attributeSet.supportsPhoneCall = true
        }
        Shared.imageCache.fetch(URL: NSURL(string:  self.avatarURL!)!).onSuccess { image in
            attributeSet.thumbnailData = UIImageJPEGRepresentation(image, 0.9)
        }
        return attributeSet
    }

    var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: self.string_id, domainIdentifier: Professional.domainIdentifier, attributeSet: self.attributeSet)
    }
}

func ==(lhs: Professional, rhs: Professional) -> Bool {
    return lhs.string_id == rhs.string_id
}

struct PaginatedReply:Mappable {
    var professionals:[Professional]?
    var meta:PaginatedReplyMeta?

    // MARK: JSON
    init?(_ map: Map) { }

    mutating func mapping(map: Map) {
        professionals <- map["data"]
        meta <- map["meta.pagination"]
    }
}

struct PaginatedReplyMeta:Mappable {
    var total:Int?
    var count:Int?
    var perPage:Int?
    var currentPage:Int?
    var totalPages:Int?
    var links:PaginationLinks?

    init() {}

    // MARK: JSON
    init?(_ map: Map) { }

    mutating func mapping(map: Map) {
        total <- map["total"]
        count <- map["count"]
        perPage <- map["per_page"]
        currentPage <- map["current_page"]
        totalPages <- map["total_pages"]
        links <- map["links"]
    }

    func hasMorePages() -> Bool {
        if currentPage == nil {
            return false
        }
        return currentPage < totalPages
    }
}

struct PaginationLinks:Mappable {
    var next:String?
    var previous:String?

    // MARK: JSON
    init?(_ map: Map) { }

    mutating func mapping(map: Map) {
        next <- map["next"]
        previous <- map["previous"]
    }
}

struct PrivateInfo:Mappable {
    var phone:String?

    // MARK: JSON
    init?(_ map: Map) { }

    mutating func mapping(map: Map) {
        phone <- map["data.phone"]
    }

}
