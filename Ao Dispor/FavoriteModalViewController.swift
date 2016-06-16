//
//  FavoriteModalViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 13/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import MobileCoreServices
import MessageUI

class FavoriteModalViewController: UIViewController {
    var professional = Professional()

    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var rate : UILabel!
    @IBOutlet weak var profileDescription : UIWebView!

    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var unfavoriteButton: UIButton!

    override func loadView() {
        super.loadView()
        //self.view = NSBundle.mainBundle().loadNibNamed("ProfessionalCard", owner: self, options: nil)[0] as? ProfessionalCard
        //self.view.layer.cornerRadius = 10
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*let view = self.view as? ProfessionalCard
        view?.fillWithData(professional)
        view?.shouldShowFullDescription = false*/

        self.contactButton.setTitle(NSLocalizedString("Contactar", comment: ""), forState: .Normal)
        self.unfavoriteButton.setTitle(NSLocalizedString("Desfavoritar", comment: ""), forState: .Normal)

        self.avatar.af_setImageWithURL(NSURL(string: professional.avatarURL)!)
        self.name?.text = professional.name
        self.titleLabel.attributedText = self.getMutableStringWithHighlightedText(professional.title)

        if(professional.type == "S") {
            self.rate?.textColor = UIColor.serviceGreen()
            self.rate?.text = "\(professional.rate) €"
        } else if (professional.type == "H") {
            self.rate?.textColor = UIColor.perHourBlue()
            self.rate?.text = "\(professional.rate) €/h"
        }

        do {
            let url = NSBundle.mainBundle().pathForResource("profileDescription", ofType:"html")
            let templateHTML = try String(contentsOfFile: url!)
            let finalHTML = templateHTML.stringByReplacingOccurrencesOfString("{{text}}", withString: professional.description)
            self.profileDescription?.loadHTMLString(finalHTML, baseURL: nil)
        } catch {
            print(error)
        }

    }

    private func getMutableStringWithHighlightedText(string: String) -> NSMutableAttributedString {
        let hightlightedString = NSMutableAttributedString(string: string)

        let range = (string as NSString).rangeOfString("<highlight>(.*?)</highlight>", options:.RegularExpressionSearch)
        hightlightedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: range)
        hightlightedString.mutableString.replaceOccurrencesOfString("<highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))
        hightlightedString.mutableString.replaceOccurrencesOfString("</highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))

        return hightlightedString
    }


    @IBAction func contactProfessional(sender: AnyObject) {
        let string_id = professional.string_id

        API.sharedInstance.telephoneFor(string_id).then { privateInfo in
            let string = NSLocalizedString("Entre imediatamante em contacto com este profissional através do número:", comment: "")
            let alertController = UIAlertController(title: NSLocalizedString("Contactar este profissional", comment:""), message: "\(string)\n\(privateInfo.phone)", preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)

            let OKAction = UIAlertAction(title: NSLocalizedString("Telefonar", comment:""), style: .Default) { (action) in
                let phone = "tel://\(privateInfo.phone)"
                let open = NSURL(string: phone)!

                UIApplication.sharedApplication().openURL(open)
            }
            alertController.addAction(OKAction)

            let SMSAction = UIAlertAction(title: NSLocalizedString("Enviar SMS", comment:""), style: .Default) { (action) in
                let messageVC = MFMessageComposeViewController()
                messageVC.body = "";
                messageVC.recipients = [privateInfo.phone]
                messageVC.messageComposeDelegate = self;

                self.presentViewController(messageVC, animated: true, completion: nil)
            }
            alertController.addAction(SMSAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}

//MARK: - UIWebViewDelegate
extension FavoriteModalViewController:UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSizeZero)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension FavoriteModalViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
