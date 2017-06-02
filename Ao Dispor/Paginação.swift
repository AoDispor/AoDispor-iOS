//
//  Paginação.swift
//  Ao Dispor
//
//  Created by André Lamelas on 24/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import SwiftyJSON
import Foundation

struct Página {
    let profissionais : [Profissional]
    let meta: DadosDePágina

    init(json: JSON) {
        profissionais = json["data"].arrayValue.map { Profissional(json: $0) } as [Profissional]
        meta            = DadosDePágina(json: json["meta"]["pagination"])
    }

    var temMaisPáginas: Bool {
        get {
            return meta.temMaisPáginas
        }
    }

    var páginaSeguinte: Int {
        get {
            return meta.páginaSeguinte
        }
    }
}

struct DadosDePágina {
    let total: Int
    let count: Int
    let porPágina: Int
    let páginaActual: Int
    let totalDePáginas: Int
    let links: Links

    init(json: JSON) {
        total = json["total"].intValue
        count = json["count"].intValue
        porPágina = json["per_page"].intValue
        páginaActual = json["current_page"].intValue
        totalDePáginas = json["total_pages"].intValue
        links = Links(json: json["links"])
    }

    var temMaisPáginas: Bool {
        get {
            return self.páginaActual < totalDePáginas
        }
    }

    var páginaSeguinte: Int {
        get {
            if(temMaisPáginas) {
                return self.páginaActual + 1
            }
            return -1
        }
    }
}

struct Links {
    var próximo: URL?
    var anterior: URL?

    init(json: JSON) {
        if let próximo = json["next"].string {
            self.próximo = URL(string: próximo)!
        }

        if let anterior = json["previous"].string {
            self.anterior = URL(string: anterior)!
        }
    }
}
