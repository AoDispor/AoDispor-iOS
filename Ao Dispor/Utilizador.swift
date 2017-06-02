//
//  Utilizador.swift
//  Ao Dispor
//
//  Created by André Lamelas on 17/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//
import SwiftyJSON

struct Utilizador {
    let uuid          : String
    let postal_code : String?
    let telephone    : String

    init(json: JSON) {
        uuid          = json["uuid"].stringValue
        postal_code = json["postal_code"].string
        telephone   =  json["telephone"].stringValue
    }
}
