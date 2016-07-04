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
import CoreSpotlight

enum APIService {
    case Search(searchData: SearchData)
    case TelephoneFor(string_id: String)
    // FIXME Isto não devia fazer um pedido à rede!
    case ProfileFor(string_id: String)
}

let endpointClosure = { (target: APIService) -> Endpoint<APIService> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<APIService> = Endpoint<APIService>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)

    let date = NSDate()
    var formatter = NSDateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    let utcString = formatter.stringFromDate(date)
    let token = "4bsHGsYeva6eud8VsLiKEVVQYQEgmfCafwtuNrhuFYFcPjxWnT\(utcString)"

    //FIXME codificar o token
    return endpoint.endpointByAddingHTTPHeaderFields(["API-Authorization": token])
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
        case .ProfileFor(let string_id):
            return "/profiles/profile/profile/\(string_id)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .Search, .TelephoneFor, .ProfileFor:
            return .GET
        }
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .Search(let searchData):
            return searchData.serialize()
        case .TelephoneFor(let string_id):
            return ["string_id": string_id]
        case .ProfileFor(let string_id):
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
        case .ProfileFor(let string_id):
            return "{\"string_id\":\"\(string_id)\"}".UTF8EncodedData
        }
    }
}

protocol APIReplyDelegate:class {
    func returnProfessionals(professionals:[Professional], meta:PaginatedReplyMeta)
    func returnPrivateInfo(privateInfo:PrivateInfo)
    func returnProfessional(professional:Professional)
}

extension APIReplyDelegate {
    func returnProfessionals(professionals:[Professional], meta:PaginatedReplyMeta) {}
    func returnPrivateInfo(privateInfo:PrivateInfo) {}
    func returnProfessional(professional:Professional) {}
}

class API {
    static let sharedInstance = API()

    let provider = MoyaProvider<APIService>(endpointClosure: endpointClosure)
    var searchData = SearchData()
    var delegate:APIReplyDelegate?

    func search() {
        provider.request(.Search(searchData: self.searchData)) { result in
            switch result {
            case let .Success(response):
                do {
                    if let paginatedReply:PaginatedReply? = try response.mapObject(PaginatedReply) {
                        self.delegate?.returnProfessionals(paginatedReply!.professionals!, meta: paginatedReply!.meta!)
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
                    if let privateInfo:PrivateInfo = try response.mapObject(PrivateInfo)
                    {
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

    func profileFor(string_id: String) {
        provider.request(.ProfileFor(string_id: string_id)) { result in
            switch result {
            case let .Success(response):
                do {
                    if let paginatedReply:PaginatedReply? = try response.mapObject(PaginatedReply) {
                        self.delegate?.returnProfessional(paginatedReply!.professionals!.first!)
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

class LoadAllAndIndex:APIReplyDelegate {
    var searchData = SearchData()
    let api = API()

    init() {
        self.searchData.perPage = 1000
        self.api.searchData = self.searchData
        self.api.delegate = self
    }

    func returnProfessionals(professionals: [Professional], meta: PaginatedReplyMeta) {
        let profilesToIndex = Professional.searchableItems(professionals)
        Indexer.index(profilesToIndex)
    }

    static func getAllProfessionals() {
        let ob = LoadAllAndIndex()
        ob.api.search()
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

        ret["page_size"] = self.perPage

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
