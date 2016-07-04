//
//  ContactAlertViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 23/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import MessageUI
import Crashlytics

class ContactAlertViewController : NSObject {
    let professional:Professional
    let viewController:UIViewController

    init(professional:Professional, viewController:UIViewController) {
        self.professional = professional
        self.viewController = viewController
    }

    func showContactAlertViewController() {
        API.sharedInstance.privateInfoFor(professional.string_id!)
        API.sharedInstance.delegate = self
    }
}

//MARK: - APIReplyDelegate
extension ContactAlertViewController:APIReplyDelegate {
    func returnPrivateInfo(privateInfo: PrivateInfo) {
        /*let string = NSLocalizedString("Entre imediatamante em contacto com este profissional através do número:", comment: "")
        let alertController = UIAlertController(title: NSLocalizedString("Contactar este profissional", comment:""), message: "\(string)\n\(privateInfo.phone!)", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: NSLocalizedString("Telefonar", comment:""), style: .Default) { (action) in
            let phone = "tel://\(privateInfo.phone!)"
            let open = NSURL(string: phone)!
            Answers.logCustomEventWithName("Telefonema", customAttributes: ["string_id": self.string_id
                ])
            UIApplication.sharedApplication().openURL(open)
        }
        alertController.addAction(OKAction)

        let SMSAction = UIAlertAction(title: NSLocalizedString("Enviar SMS", comment:""), style: .Default) { (action) in
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Vi o seu perfil no AoDispor.pt e gostaria de contratar os seus serviços. Podemos falar?";
            messageVC.recipients = [privateInfo.phone!]
            messageVC.messageComposeDelegate = self;
            Answers.logCustomEventWithName("Envio de SMS", customAttributes: ["string_id": self.string_id
                ])
            self.viewController.presentViewController(messageVC, animated: true, completion: nil)
        }
        alertController.addAction(SMSAction)
        
        self.viewController.presentViewController(alertController, animated: true, completion: nil)*/
        //let string = NSLocalizedString("Entre imediatamante em contacto com este profissional através do número:", comment: "")
        //let alertController = UIAlertController(title: NSLocalizedString("Contactar este profissional", comment:""), message: "\(string)\n\(privateInfo.phone!)", preferredStyle: .ActionSheet)

        let alertController = UIAlertController(title: professional.name, message: nil, preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: NSLocalizedString("Telefonar", comment:""), style: .Default) { (action) in
            let phone = "tel://\(privateInfo.phone!)"
            let open = NSURL(string: phone)!
            Answers.logCustomEventWithName("Telefonema", customAttributes: ["string_id": self.professional.string_id!
                ])
            UIApplication.sharedApplication().openURL(open)
        }
        alertController.addAction(OKAction)

        let SMSAction = UIAlertAction(title: NSLocalizedString("Enviar SMS", comment:""), style: .Default) { (action) in
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Vi o seu perfil no AoDispor.pt e gostaria de contratar os seus serviços. Podemos falar?"
            messageVC.recipients = [privateInfo.phone!]
            messageVC.messageComposeDelegate = self;
            Answers.logCustomEventWithName("Envio de SMS", customAttributes: ["string_id": self.professional
                .string_id!
                ])
            self.viewController.presentViewController(messageVC, animated: true, completion: nil)
        }
        alertController.addAction(SMSAction)

        var favoriteActionLabel = NSLocalizedString("Adicionar aos Favoritos", comment:"")

        if Favorites.isFavorite(self.professional) {
            favoriteActionLabel = NSLocalizedString("Remover dos Favoritos", comment:"")
        }
        let FavoriteAction = UIAlertAction(title: favoriteActionLabel, style: .Default) { (action) in
            let result = Favorites.appendOrRemove(self.professional)

            if result {
                Answers.logCustomEventWithName("Adicionar aos Favoritos", customAttributes: ["string_id": self.professional.string_id!])
            } else {
                Answers.logCustomEventWithName("Removido dos Favoritos", customAttributes: ["string_id": self.professional.string_id!])
            }
        }
        alertController.addAction(FavoriteAction)

        let ShareAction = UIAlertAction(title: NSLocalizedString("Partilhar", comment: ""), style: .Default) { (action) in
            let url = "http://www.aodispor.pt/\(self.professional.string_id!)"
            let professionalURL = NSURL(string: url)
            let objectsToShare:[AnyObject] = [professionalURL!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            self.viewController.presentViewController(activityVC, animated: true, completion: nil)
        }
        alertController.addAction(ShareAction)

        self.viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension ContactAlertViewController: MFMessageComposeViewControllerDelegate {
    @objc func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
