//
//  EditorPreço.swift
//  Ao Dispor
//
//  Created by André Lamelas on 13/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import InputMask
import Siesta

class EditorPreço: PerfilSuperViewController {
    @IBOutlet weak var tipoDePreço: UISegmentedControl!
    @IBOutlet weak var preçoTexto: UITextField!

    let maskedDelegate = MaskedTextFieldDelegate(format: "[099]")
    var statusOverlay = ResourceStatusOverlay()

    var preço: InformaçõesDePreço!

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleView = UILabel()
        titleView.text = NSLocalizedString("O Seu Preço", comment: "")
        titleView.font = UIFont(name: "DancingScriptOT", size: 36)
        titleView.textColor = UIColor.white

        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 44))
        self.navigationItem.titleView = titleView

        maskedDelegate.listener = self
        preçoTexto?.delegate = maskedDelegate

        tipoDePreço?.addTarget(self, action: #selector(self.mudarTipoDePreço), for: .valueChanged)

        if preço == nil {
            preço = InformaçõesDePreço()
        }

        preçoTexto?.text = String(preço.valor)
        switch preço.tipo! {
        case "H":
            self.tipoDePreço?.selectedSegmentIndex = 0
        case "D":
            self.tipoDePreço?.selectedSegmentIndex = 1
        case "S":
            self.tipoDePreço?.selectedSegmentIndex = 2
        default:
            break
        }

        preçoTexto?.becomeFirstResponder()

        AoDisporAPI.meuPerfilResource().addObserver(self).addObserver(statusOverlay)
        self.statusOverlay.embed(in: self)
    }

    override func viewDidLayoutSubviews() {
        self.statusOverlay.positionToCoverParent()
    }

    func mudarTipoDePreço() {
        switch self.tipoDePreço.selectedSegmentIndex {
        case 0:
            self.preço.tipo = "H"
        case 1:
            self.preço.tipo = "D"
        case 2:
            self.preço.tipo = "S"
        default:
            break
        }

        AoDisporAPI.actualizarPerfil(parâmetros: ["pricing_type": self.preço.tipo!]).onFailure { _ in
            // TODO: Mostrar erro quando não conseguir actualizar tipo de preço
        }
    }

    override func voltar() {
        AoDisporAPI.actualizarPerfil(parâmetros: ["rate": String(self.preço.valor)]).onSuccess { _ in
            self.navigationController?.popViewController(animated: true)
        }.onFailure { error in
            // TODO: Mostrar erro quando não conseguir alterar o preço
            print(error)
        }
    }
}

extension EditorPreço: MaskedTextFieldDelegateListener {
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if complete == true {
            self.preço.valor = Int(value)!
        }
    }
}

extension EditorPreço: ResourceObserver {
    func resourceChanged(_ resource: Resource, event: ResourceEvent) { }
}
