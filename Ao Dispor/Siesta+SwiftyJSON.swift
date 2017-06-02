//
//  Siesta+SwiftyJSON.swift
//  Ao Dispor
//
//  Created by André Lamelas on 17/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import SwiftyJSON
import Siesta

/// Add to a reponse pipeline to wrap JSON responses with SwiftyJSON
let SwiftyJSONTransformer =
    ResponseContentTransformer(transformErrors: true)
    { JSON($0.content as AnyObject) }

/// Provides a .json convenience accessor to get raw JSON from resources
extension TypedContentAccessors {
    var json: JSON {
        return typedContent(ifNone: JSON.null)
    }
}

