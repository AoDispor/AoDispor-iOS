//
//  PerfilViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 05/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Siesta
import ImagePicker

class PerfilViewController: PerfilSuperViewController {
    var profissional: Profissional?

    var cartãoEditável: CartãoProfissionalEditável?

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!

    var statusOverlay = ResourceStatusOverlay()

    override func viewDidLoad() {
        super.viewDidLoad()

        cartãoEditável = Bundle.main.loadNibNamed("CartãoProfissionalEditável", owner: self, options: nil)![0] as? CartãoProfissionalEditável
        cartãoEditável?.frame = KolodaViewCartas.frameParaCartaZero(para: self.view)
        self.outerView.addSubview(cartãoEditável!)

        let titleView = UILabel()
        titleView.text = NSLocalizedString("O Seu Perfil", comment: "")
        titleView.font = UIFont(name: "DancingScriptOT", size: 36)
        titleView.textColor = UIColor.white

        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 44))
        self.navigationItem.titleView = titleView

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.esconderTeclado))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let botãoDireito = UIBarButtonItem(title: NSLocalizedString("Sair", comment:""), style: .done, target: self, action: #selector(self.fazerLogOff))
        botãoDireito.tintColor = UIColor.white
        botãoDireito.icon(from: .FontAwesome, code: "sign-out", ofSize: 20)
        self.navigationItem.rightBarButtonItem = botãoDireito

        self.cartãoEditável?.localidade.delegate = self
        self.cartãoEditável?.localidade.addTarget(self, action: #selector(self.mostraSelectorCódigoPostal), for: .editingDidBegin)

        self.cartãoEditável?.preço.delegate = self
        self.cartãoEditável?.preço.addTarget(self, action: #selector(self.mostraEditorPreço), for: .editingDidBegin)

        let outroTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.mostraSelectorAvatar))
        outroTap.numberOfTapsRequired = 1
        self.cartãoEditável?.avatar.isUserInteractionEnabled = true
        self.cartãoEditável?.avatar.addGestureRecognizer(outroTap)

        AoDisporAPI.meuPerfilResource().addObserver(self).addObserver(statusOverlay)
        self.statusOverlay.embed(in: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        AoDisporAPI.meuPerfilResource().load()
    }

    override func viewDidLayoutSubviews() {
        self.statusOverlay.positionToCoverParent()
    }

    func fazerLogOff() {
        AoDisporAPI.sair()
        self.voltar()
    }

    func mostraSelectorAvatar() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        imagePickerController.startOnFrontCamera = true
        self.present(imagePickerController, animated: true, completion: nil)
    }

    // MARK: - Segues
    func mostraSelectorCódigoPostal() {
        self.performSegue(withIdentifier: "mostraSelectorCódigoPostal", sender: self)
    }

    func mostraEditorPreço() {
        self.performSegue(withIdentifier: "mostraEditorPreço", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else { return }

        switch segueId {
            case "mostraSelectorCódigoPostal":
                let vc = segue.destination as? SelectorCódigoPostal
                vc?.códigoPostalString = self.profissional?.códigoPostal
                break
            case "mostraEditorPreço":
                let vc = segue.destination as? EditorPreço
                vc?.preço = self.profissional?.informaçãoDePreço
                break
            default:
                break
        }
    }

    // MARK: - Cenas do teclado e de mover o cartão para cima
    func esconderTeclado() {
        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)

            let maximo = (self.cartãoEditável?.avatar.frame.origin.x)! + (self.cartãoEditável?.avatar.frame.size.height)! + 24

            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomHeight?.constant = 0.0
            } else {
                self.bottomHeight?.constant = maximo
            }

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.outerView.layoutIfNeeded() },
                           completion: nil)
        }
    }

    // Update dos campos de texto: profissão, nome e descrição
    func keyboardWillHide(notification: NSNotification) {
        var parâmetros = [String: String]()

        if self.cartãoEditável?.profissão.text != self.profissional?.profissão {
            parâmetros["title"] = self.cartãoEditável?.profissão.text
        }

        if self.cartãoEditável?.descrição.textView.text != self.profissional?.descrição {
            parâmetros["description"] = self.cartãoEditável?.descrição.textView.text
        }

        if self.cartãoEditável?.nomeCompleto.text != self.profissional?.nomeCompleto {
            parâmetros["full_name"] = self.cartãoEditável?.nomeCompleto.text
        }

        if parâmetros.isEmpty {
            return
        }

        AoDisporAPI.actualizarPerfil(parâmetros: parâmetros).onSuccess { _ in
            print("Perfil actualizado com sucesso")
        }
    }
}

extension PerfilViewController: ResourceObserver {
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        if case .newData = event {
            //AoDisporAPI.perfil = resource.typedContent()! as Profissional
            self.profissional = resource.typedContent()! as Profissional
            self.cartãoEditável?.preencherComDados(profissional: self.profissional!)
        }
    }
}

// Isto é para evitar o teclado de ser mostrado quando se faz tap na localização e no preço
extension PerfilViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.cartãoEditável?.preço {
            self.mostraEditorPreço()
        } else if textField == self.cartãoEditável?.localidade {
            self.mostraSelectorCódigoPostal()
        }
        return false
    }
}

extension PerfilViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper")
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done")
        imagePicker.dismiss(animated: true) {
            AoDisporAPI.uploadAvatar(imagem: UIImageJPEGRepresentation(images.first!, 0.7)!).onSuccess { data in
                print(data)
            }.onFailure { (error) in
                print(error)
            }
        }

    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
