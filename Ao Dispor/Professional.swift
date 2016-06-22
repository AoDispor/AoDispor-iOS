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

class Professional: Mappable, Storable, Equatable {
    var name:String?
    var title:String?
    var rate:String?
    var currency:String?
    var avatar:String?
    var avatarURL:String? {
        get {
            return avatar?.stringByReplacingOccurrencesOfString("regular", withString: "original")
        }
    }
    var description:String?
    var type:String?
    var string_id:String?
    var location:String?

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
        return ret
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
