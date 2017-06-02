//
//  CódigoPostal.swift
//  Ao Dispor
//
//  Created by André Lamelas on 17/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//
import SwiftyJSON

struct CódigoPostal {
    var cp4:String
    var cp3:String
    var localidade:String
    var latitude:String
    var longitude:String

    init(json: JSON) {
        cp4 = json["cp4"].stringValue
        cp3 = json["cp3"].stringValue
        localidade = json["localidade"].stringValue
        latitude = json["latitude"].stringValue
        longitude = json["longitude"].stringValue
    }
}
