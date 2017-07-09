//
//  SelectorCódigoPostal.swift
//  
//
//  Created by André Lamelas on 12/06/17.
//
//

import UIKit
import InputMask
import SwiftLocation

class SelectorCódigoPostal: PerfilSuperViewController {
    @IBOutlet weak var códigoPostal: UITextField?
    @IBOutlet weak var mensagemInformativa: UILabel?

    let maskedDelegate = MaskedTextFieldDelegate(format: "[0000]{-}[000]")

    var códigoPostalString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleView = UILabel()
        titleView.text = NSLocalizedString("Código Postal", comment: "")
        titleView.font = UIFont(name: "DancingScriptOT", size: 36)
        titleView.textColor = UIColor.white

        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 44))
        self.navigationItem.titleView = titleView

        maskedDelegate.listener = self
        códigoPostal?.delegate = maskedDelegate

        códigoPostal?.text = códigoPostalString ?? nil

        códigoPostal?.becomeFirstResponder()
    }
}

extension SelectorCódigoPostal: MaskedTextFieldDelegateListener {
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if complete {
            let componentes = value.components(separatedBy: "-")
            // FIXME É preciso enviar a localização correcta quando for altura!
            /*AoDisporAPI.actualizarPerfil(parâmetros: ["cp4": componentes[0], "cp3": componentes[1], "location": "dummy"]).onSuccess({ data in
                let profissional = data.typedContent()! as Profissional
                self.mensagemInformativa!.text = String.localizedStringWithFormat(NSLocalizedString("A sua localização é:\n%@", comment: ""), profissional.localidade)
            }).onFailure({ (data) in
                self.mensagemInformativa!.text = NSLocalizedString("Não foi possível gravar o seu código postal. Por favor tente de novo.", comment: "")
            })*/

            AoDisporAPI.códigoPostal(cp4: componentes[0], cp3: componentes[1]).onSuccess({ data in
                let códigoPostal = data.typedContent()! as CódigoPostal
                AoDisporAPI.actualizarPerfil(parâmetros: ["cp4": códigoPostal.cp4, "cp3": códigoPostal.cp3, "location": códigoPostal.localidade]).onSuccess({ data in
                    let profissional = data.typedContent()! as Profissional
                    self.mensagemInformativa!.text = String.localizedStringWithFormat(NSLocalizedString("A sua localização é:\n%@", comment: ""), profissional.localidade)
                }).onFailure({ _ in
                    self.mensagemInformativa!.text = NSLocalizedString("Não foi possível gravar o seu código postal. Por favor tente de novo.", comment: "")
                })
                self.mensagemInformativa!.text = String.localizedStringWithFormat(NSLocalizedString("A sua localização é:\n%@", comment: ""), códigoPostal.localidade)
            }).onFailure({ _ in
                self.mensagemInformativa!.text = NSLocalizedString("Não foi possível encontrar o seu código postal. Verifique se o inseriu correctamente.", comment: "")
            })
        }
    }
}
