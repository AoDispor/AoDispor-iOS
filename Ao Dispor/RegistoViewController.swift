//
//  RegistoViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class RegistoViewController: UIViewController {
    @IBOutlet weak var nãoRegistar: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.titleBlue

        self.navigationController?.navigationBar.barTintColor = UIColor.titleBlue
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        let botãoEsquerdo = UIBarButtonItem(title: NSLocalizedString("Anterior", comment:""), style: .done, target: self, action: #selector(RegistoViewController.voltar))
        botãoEsquerdo.tintColor = UIColor.white
        botãoEsquerdo.icon(from: .FontAwesome, code: "chevron-left", ofSize: 20)
        self.navigationItem.leftBarButtonItem = botãoEsquerdo
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationBarTransparente()
    }

    @IBAction func nãoMeInscreverAgora(sender: UIButton) {
        self.navigationBarTransparente()
        self.navigationController?.popToRootViewController(animated: true)
    }

    func voltar() {
        self.navigationController?.popViewController(animated: true)
    }

    private func navigationBarTransparente() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
