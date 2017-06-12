//
//  CartãoTextoImagem.swift
//  Ao Dispor
//
//  Created by André Lamelas on 01/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class CartãoTextoImagem: Cartão {
    @IBOutlet weak var texto: MarginLabel!
    @IBOutlet weak var subtexto: UITextView!
    @IBOutlet weak var imagem: UIImageView!

    static func criarCartão(texto: String, subtexto: String, imagem: UIImage) -> CartãoTextoImagem {
        let cartão = Bundle.main.loadNibNamed("CartãoTextoImagem", owner: self, options: nil)![0] as? CartãoTextoImagem
        cartão?.texto?.text = NSLocalizedString("", comment: "")
        cartão?.subtexto?.text = NSLocalizedString("Parece que não existem resultados.", comment: "")
        cartão?.imagem?.image = imagem
        return cartão!
    }
}
