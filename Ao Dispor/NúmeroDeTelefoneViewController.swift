//
//  NúmeroDeTelefoneViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 06/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import PhoneNumberKit

class NúmeroDeTelefoneViewController: RegistoViewController {
    @IBOutlet weak var novoUtilizador: BotãoAoDispor!
    @IBOutlet weak var telefone: PhoneNumberTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            self.telefone.text = "+351912461135"
        #else
            self.telefone.text = "+351"
        #endif
        self.telefone.defaultRegion = "PT"
        self.telefone.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mostraValidarTelefone" {
            let controller = segue.destination as? ValidarPasswordViewController
            controller?.telefone = self.telefone.text!
        }
    }

    @IBAction func registo(sender: UIButton) {
        AoDisporAPI.registar(self.telefone.text!).onSuccess { (_) in
            self.performSegue(withIdentifier: "mostraValidarTelefone", sender: self)
        }
    }
}
