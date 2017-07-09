//
//  PerfilSuperViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 12/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class PerfilSuperViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let botãoEsquerdo = UIBarButtonItem(title: NSLocalizedString("Anterior", comment:""), style: .done, target: self, action: #selector(PerfilViewController.voltar))
        botãoEsquerdo.tintColor = UIColor.white
        botãoEsquerdo.icon(from: .FontAwesome, code: "chevron-left", ofSize: 20)
        self.navigationItem.leftBarButtonItem = botãoEsquerdo
    }

    func voltar() {
        self.navigationController?.popViewController(animated: true)
    }
}
