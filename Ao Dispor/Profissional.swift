//
//  Profissional.swift
//  Ao Dispor
//
//  Created by André Lamelas on 23/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import SwiftyJSON

struct Profissional {
    var nomeCompleto: String
    var stringId: String
    var profissão: String
    var descrição: String
    var preço: Int
    var unidadeMonetária: String
    var tipoDePreço: String
    var localidade: String
    var endereçoDoAvatar: String
    var telefone: String
    var distância: Float

    var profissãoComoAttributedString: NSAttributedString {
        return self.profissão.getMutableStringWithHighlightedText()
    }

    var distânciaArredondadaComUnidade: String {
        if self.distância <= 1000 {
            return "a " + Int(self.distância).description + " metros"
        } else if self.distância >= 1000 {
            return "a " + Int(self.distância/1000).description + " km"
        }
        return ""
    }

    var descriçãoHTML: String? {
        do {
            let url = Bundle.main.path(forResource: "profileDescription", ofType:"html")
            let templateHTML = try String(contentsOfFile: url!)
            return templateHTML.replacingOccurrences(of: "{{text}}", with: self.descrição)
        } catch {
            return "could not load profile description"
        }
    }

    var informaçãoDePreço: InformaçõesDePreço {
        return InformaçõesDePreço(tipo: self.tipoDePreço, valor: self.preço, unidadeMonetária: self.unidadeMonetária)
    }

    init(json: JSON) {
        nomeCompleto = json["full_name"].stringValue
        stringId = json["string_id"].stringValue
        profissão = json["title"].stringValue
        descrição = json["description"].stringValue
        preço = json["rate"].intValue
        unidadeMonetária = json["currency"].stringValue
        tipoDePreço = json["type"].stringValue
        localidade = json["location"].stringValue
        endereçoDoAvatar = json["avatar_url"].stringValue
        telefone = json["phone"].stringValue
        distância = json["distance"].floatValue
    }
}

struct InformaçõesDePreço {
    var tipo: String?
    var valor: Int = 0
    var unidadeMonetária: String = "EUR"

    var stringDoPreço: String? {
        if self.tipo == "S" {
            return "\(self.valor) \(self.unidadeMonetária)"
        } else if self.tipo == "H" {
            return "\(self.valor) \(self.unidadeMonetária)/h"
        } else if self.tipo == "D" {
            return "\(self.valor) \(self.unidadeMonetária)/d"
        }
        return "\(self.valor) \(self.unidadeMonetária)"
    }
}
