//
//  Utilizador.swift
//  Ao Dispor
//
//  Created by André Lamelas on 17/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//
import SwiftyJSON
import Locksmith

struct ContaAoDispor: InternetPasswordSecureStorable, ReadableSecureStorable, CreateableSecureStorable {
    let username: String
    let password: String

    var account: String { return username }
    var data: [String: Any] {
        return ["password": password]
    }

    let server = "api.aodispor.pt"
    let port = 80
    let internetProtocol = LocksmithInternetProtocol.https
    let authenticationType = LocksmithInternetAuthenticationType.httpBasic
}

struct Utilizador {
    let uuid: String
    let códigoPostal: String?
    let telephone: String

    init(json: JSON) {
        uuid          = json["uuid"].stringValue
        códigoPostal = json["postal_code"].string
        telephone   =  json["telephone"].stringValue
    }
}
