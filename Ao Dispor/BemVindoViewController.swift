//
//  BemVindoViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 06/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class BemVindoViewController: RegistoViewController {
    @IBOutlet weak var seguinte: BotãoAoDispor!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguinte" {
            _ = segue.destination as? NúmeroDeTelefoneViewController
        }
    }

    @IBAction func seguinte(sender: UIButton) {
        performSegue(withIdentifier: "pedeNúmeroDeTelefone", sender: self)
    }
}
