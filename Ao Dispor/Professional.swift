//
//  Professional.swift
//  Ao Dispor
//
//  Created by André Lamelas on 16/05/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import Foundation
import Arrow
import thenPromise
import ws

class API {
    static let sharedInstance = API()

    let ws = WS("https://api.aodispor.pt")
    //let ws = WS("http://dev.api.aodispor.pt")
    var searchData = SearchData()
    var waiting = false

    init() {
        ws.logLevels = .Calls
    }

    func search() -> Promise<PaginatedReply> {
        return ws.get("/profiles/search", params: searchData.serialize())
    }

    func telephoneFor(string_id:String) -> Promise<PrivateInfo> {
        return ws.get("/profiles/profile/phone/\(string_id)")
    }
}

struct SearchData {
    var query:String = ""
    //var avatar:Bool = true
    var lat:Double = Double.NaN
    var lon:Double = Double.NaN
    var location:String = ""
    var page:Int = 0
    var perPage:Int = 64

    func serialize() -> [String: AnyObject] {
        var ret = [String:AnyObject]()

        if(!query.isEmpty) {
            ret["query"] = self.query
        }

        if(lat.isFinite && lon.isFinite && !lat.isNaN && !lon.isNaN) {
            ret["lat"] = self.lat
            ret["lon"] = self.lon
        } else if(!location.isEmpty) {
            ret["location"] = self.location
        }

        /*if(avatar) {
            ret["avatar"] = true
        }*/

        if(page == 0) {
            ret["page"] = self.page + 1
        } else {
            ret["page"] = self.page
        }
        
        return ret
    }
}

struct Professional {
    var name:String = ""
    var title:String = ""
    var rate:String = ""
    var currency:String = ""
    var avatarURL:String = ""
    var description:String = ""
    var type:String = ""
    var string_id:String = ""
    var location:String = ""
}

extension Professional:ArrowParsable {
    mutating func deserialize(json: JSON) {
        name <-- json["full_name"]
        rate <-- json["rate"]
        currency <-- json["currency"]
        title <-- json["title"]
        description <-- json["description"]
        avatarURL <-- json["avatar_url"]
        type <-- json["type"]
        string_id <-- json["string_id"]
        location <-- json["location"]
    }
}

struct PaginatedReply {
    var data:[Professional] = []
    var meta:PaginatedReplyMeta = PaginatedReplyMeta()
}

extension PaginatedReply:ArrowParsable {
    mutating func deserialize(json: JSON) {
        data <-- json["data"]
        meta <-- json["meta"]?["pagination"]
    }
}

struct PaginatedReplyMeta {
    var total:Int = 0
    var count:Int = 0
    var perPage:Int = 0
    var current_page:Int = 0
    var totalPages:Int = 0
    var links:PaginationLinks = PaginationLinks()
}

extension PaginatedReplyMeta:ArrowParsable {
    mutating func deserialize(json: JSON) {
        total <-- json["total"]
        count <-- json["count"]
        perPage <-- json["per_page"]
        current_page <-- json["current_page"]
        totalPages <-- json["total_pages"]
        links <-- json["links"]
    }
}

struct PaginationLinks {
    var next:String = ""
    var previous:String = ""
}

extension PaginationLinks:ArrowParsable {
    mutating func deserialize(json: JSON) {
        next <-- json["next"]
        previous <-- json["previous"]
    }
}

struct PrivateInfo {
    var phone:String = ""
}

extension PrivateInfo:ArrowParsable {
    mutating func deserialize(json: JSON) {
        phone <-- json["data"]?["phone"]
    }
}
