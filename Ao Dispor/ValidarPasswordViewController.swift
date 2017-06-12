//
//  ValidarPasswordViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 06/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class ValidarPasswordViewController: RegistoViewController {
    var telefone: String?
    var profissional: Profissional?

    @IBOutlet weak var validar: BotãoAoDispor!
    @IBOutlet weak var enviarDeNovo: UIButton!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.becomeFirstResponder()
    }

    @IBAction func enviarDeNovo(sender: UIButton) {
        AoDisporAPI.registar(telefone!).onCompletion { (_) in
            // TODO Era fixe mostrar daqui a quanto tempo é que se pode fazer um novo pedido
        }
    }

    @IBAction func validarPassword(sender: UIButton) {
        // TODO Validar password
        AoDisporAPI.autenticar(telefone: self.telefone!, password: self.password.text!)
        AoDisporAPI.meuPerfil().onSuccess { (data) in
            self.profissional = data.typedContent()! as Profissional
            self.performSegue(withIdentifier: "editarPerfil", sender: self)
            }.onFailure { _ in
                AoDisporAPI.sair()
                let alertController = UIAlertController(title: NSLocalizedString("Password errada", comment:""), message: NSLocalizedString("Por favor insira a password que recebeu por SMS no número de telefone que nos indicou.", comment:""), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: NSLocalizedString("Voltar", comment:""), style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarPerfil" {
            let controller = segue.destination as? PerfilViewController
            controller?.profissional = self.profissional!
        }
    }
}
