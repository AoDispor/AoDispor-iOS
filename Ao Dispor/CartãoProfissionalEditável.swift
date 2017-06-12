//
//  CartãoProfissionalEditável.swift
//  Ao Dispor
//
//  Created by André Lamelas on 05/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Siesta
import SwiftRichString

class CartãoProfissionalEditável: Cartão {
    var profissional: Profissional?

    @IBOutlet weak var localidade: UILabel!
    @IBOutlet weak var preço: UILabel!
    @IBOutlet weak var avatar: RemoteImageView! {
        didSet {
            self.avatar.contentMode = .scaleAspectFill
            self.avatar.clipsToBounds = true
        }
    }
    @IBOutlet weak var profissão: UITextField!
    @IBOutlet weak var nomeCompleto: UITextField!
    @IBOutlet weak var descrição: PlaceholderUITextView!

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.avatar.layer.borderWidth = 1
        self.avatar.layer.cornerRadius = 10
        self.avatar.layer.borderColor = UIColor.black.cgColor
    }

    func preencherComDados(profissional: Profissional) {
        self.profissional = profissional

        self.avatar.imageURL = profissional.endereçoDoAvatar

        self.profissão.text = profissional.profissão
        self.nomeCompleto.text = profissional.nomeCompleto
        self.descrição?.textView.text = profissional.descriçãoHTML

        self.localidade?.text = profissional.localidade

        if profissional.tipoDePreço == "S" {
            self.preço?.textColor = UIColor.serviceGreen
            self.preço?.text = "\(profissional.preço) €"
        } else if profissional.tipoDePreço == "H" {
            self.preço?.textColor = UIColor.perHourBlue
            self.preço?.text = "\(profissional.preço) €/h"
        }
    }
}
