//
//  CartãoProfissional.swift
//  Ao Dispor
//
//  Created by André Lamelas on 24/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Siesta
import SwiftRichString

class CartãoProfissional:Cartão {
    var profissional:Profissional?

    @IBOutlet weak var profissão : UILabel!
    @IBOutlet weak var preço : UILabel!
    @IBOutlet weak var descriçãoDoPerfil : UIWebView! {
        didSet {
            self.descriçãoDoPerfil?.dataDetectorTypes = []
        }
    }
    @IBOutlet weak var avatar : RemoteImageView! {
        didSet {
            self.avatar.contentMode = .scaleAspectFill
            self.avatar.clipsToBounds = true
        }
    }
    @IBOutlet weak var localidade : UILabel! {
        didSet {
            self.localidade?.sizeToFit()
        }
    }

    func fillWithData(profissional: Profissional) -> Void {
        self.profissional = profissional

        self.avatar.imageURL = profissional.endereçoDoAvatar

        self.profissão.attributedText = profissional.profissãoComoAttributedString
        self.descriçãoDoPerfil?.loadHTMLString(profissional.descriçãoHTML!, baseURL: nil)

        let localidade = Style("localidade", {
            $0.font = FontAttribute("YanoneKaffeesatz-Regular", size: 25)
            $0.color = UIColor.black
        })

        let distância = Style("localidade", {
            $0.font = FontAttribute("YanoneKaffeesatz-Regular", size: 16)
            $0.color = UIColor.lightGray
        })

        self.localidade?.attributedText = profissional.localidade.set(style: localidade) + " "
            + profissional.distânciaArredondadaComUnidade.set(style: distância)
        self.localidade?.sizeToFit()

        if(profissional.tipoDePreço == "S") {
            self.preço?.textColor = UIColor.serviceGreen()
            self.preço?.text = "\(profissional.preço) €"
        } else if (profissional.tipoDePreço == "H") {
            self.preço?.textColor = UIColor.perHourBlue()
            self.preço?.text = "\(profissional.preço) €/h"
        }
    }

}

