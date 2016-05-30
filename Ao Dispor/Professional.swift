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

    let ws = WS("http://api.aodispor.pt")
    var searchData = SearchData()

    init() {
        ws.logLevels = .Calls
    }

    func search() -> Promise<PaginatedReply> {
        return ws.get("/profiles/search", params: searchData.serialize())
    }
}

struct SearchData {
    var query:String = ""
    var avatar:Bool = true
    var lat:Double = Double.NaN
    var lon:Double = Double.NaN
    var location:String = ""
    var page:Int = 0
    var per_page:Int = 64

    func serialize() -> [String: AnyObject] {
        var ret = [String:AnyObject]()

        if(!query.isEmpty) {
            ret["query"] = self.query
        }

        if(lat.isFinite && lon.isFinite) {
            ret["lat"] = self.lat
            ret["lon"] = self.lon
        } else if(!location.isEmpty) {
            ret["location"] = self.location
        }

        if(avatar) {
            ret["avatar"] = true
        }

        ret["page"] = self.page

        return ret
    }
}

struct Professional {
    var name:String = ""
    var title:String = ""
    var rate:String = ""
    var avatarURL:String = ""
    var description:String = ""
    var type:String = ""
    var string_id:String = ""
}

extension Professional:ArrowParsable {
    mutating func deserialize(json: JSON) {
        name <-- json["full_name"]
        rate <-- json["rate"]
        title <-- json["title"]
        description <-- json["description"]
        avatarURL <-- json["avatar_url"]
        type <-- json["type"]
        string_id <-- json["string_id"]
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
    var per_page:Int = 0
    var current_page:Int = 0
    var total_pages:Int = 0
    var links:PaginationLinks = PaginationLinks()
}

extension PaginatedReplyMeta:ArrowParsable {
    mutating func deserialize(json: JSON) {
        total <-- json["total"]
        count <-- json["count"]
        per_page <-- json["per_page"]
        current_page <-- json["current_page"]
        total_pages <-- json["total_pages"]
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
