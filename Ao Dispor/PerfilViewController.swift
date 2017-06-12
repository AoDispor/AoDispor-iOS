//
//  PerfilViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 05/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Siesta

class PerfilViewController: UIViewController {
    var profissional: Profissional?
    var cartãoEditável: CartãoProfissionalEditável?

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!

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

        let botãoEsquerdo = UIBarButtonItem(title: NSLocalizedString("Anterior", comment:""), style: .done, target: self, action: #selector(PerfilViewController.voltar))
        botãoEsquerdo.tintColor = UIColor.white
        botãoEsquerdo.icon(from: .FontAwesome, code: "chevron-left", ofSize: 20)
        self.navigationItem.leftBarButtonItem = botãoEsquerdo

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
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

    func voltar() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
