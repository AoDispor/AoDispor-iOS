//
//  API.swift
//  Ao Dispor
//
//  Created by André Lamelas on 16/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import Foundation
import Moya
import Moya_ObjectMapper
import Pantry

enum APIService {
    case Search(searchData: SearchData)
    case TelephoneFor(string_id: String)
}

// MARK: - TargetType Protocol Implementation
extension APIService: TargetType {
    #if TARGET_OS_SIMULATOR
    var baseURL: NSURL { return NSURL(string: "http://dev.api.aodispor.pt")! }
    #else
    var baseURL: NSURL { return NSURL(string: "https://api.aodispor.pt")! }
    #endif
    
    var path: String {
        switch self {
        case .Search:
            return "/profiles/search"
        case .TelephoneFor(let string_id):
            return "/profiles/profile/phone/\(string_id)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .Search, .TelephoneFor:
            return .GET
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .Search(let searchData):
            return searchData.serialize()
        case .TelephoneFor(let string_id):
            return ["string_id": string_id]
        }
    }
    var sampleData: NSData {
        switch self {
        // TODO convem perceber o que é esta sampleData e não retornar nil
        case .Search:
            return "A".UTF8EncodedData
        case .TelephoneFor(let string_id):
            return "{\"string_id\":\"\(string_id)\"}".UTF8EncodedData
        }
    }
}

protocol APIReplyDelegate:class {
    func returnProfessionals(professionals:[Professional], meta:PaginatedReplyMeta)
    func returnPrivateInfo(privateInfo:PrivateInfo)
}

extension APIReplyDelegate {
    func returnProfessionals(professionals:[Professional], meta:PaginatedReplyMeta) {}
    func returnPrivateInfo(privateInfo:PrivateInfo) {}
}

class API {
    static let sharedInstance = API()

    let provider = MoyaProvider<APIService>()
    var searchData = SearchData()
    var delegate:APIReplyDelegate?

    func search() {
        provider.request(.Search(searchData: self.searchData)) { result in
            switch result {
            case let .Success(response):
                do {
                    if let paginatedReply = try response.mapObject() as? PaginatedReply {
                        self.delegate?.returnProfessionals(paginatedReply.professionals!, meta: paginatedReply.meta!)
                    }
                } catch {
                    // TODO: fazer alguma cena de jeito quando não consegue parsar a resposta...
                    print(".Search: Could not parse PaginatedReply")
                }
            case let .Failure(error):
                // TODO: handle the error ==  best. comment. ever.
                print(".Search: \(error)")
            }
        }
    }

    func privateInfoFor(string_id: String) {
        provider.request(.TelephoneFor(string_id: string_id)) { result in
            switch result {
            case let .Success(response):
                do {
                    if let privateInfo = try response.mapObject() as? PrivateInfo {
                        self.delegate?.returnPrivateInfo(privateInfo)
                    }
                } catch {
                    // TODO: fazer alguma cena de jeito quando não consegue parsar a resposta...
                    print(".TelephoneFor: Could not parse PaginatedReply")
                }
            case let .Failure(error):
                // TODO: handle the error ==  best. comment. ever.
                print(".TelephoneFor: \(error)")
            }
        }
    }
}

struct SearchData {
    var query:String = ""
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

        if(page == 0) {
            ret["page"] = self.page + 1
        } else {
            ret["page"] = self.page
        }

        return ret
    }
}

class Favorites {
    static private var favorites:[Professional]? {
        set {
            if let newValue = newValue {
                Pantry.pack(newValue, key: "favorites")
            }
        }
        get {
            return Pantry.itemExistsForKey("favorites") ? Pantry.unpack("favorites") : [Professional]()
        }
    }

    static func favoriteAtIndex(index:Int) -> Professional {
        return favorites![index]
    }

    static func isFavorite(favorite:Professional) -> Bool {
        return favorites!.contains(favorite)
    }

    static func appendOrRemove(favorite:Professional) -> Bool {
        if favorites!.contains(favorite) {
            let indexToRemove = favorites!.indexOf({ $0 == favorite })
            favorites!.removeAtIndex(indexToRemove!)
            return false
        }
        favorites!.append(favorite)
        return true
    }

    static func numberOfFavorites() -> Int {
        return self.favorites!.count
    }
}
