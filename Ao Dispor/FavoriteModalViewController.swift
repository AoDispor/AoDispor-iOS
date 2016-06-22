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
import Haneke

class FavoriteModalViewController: UIViewController {
    var professional:Professional?
    var delegate:DismissedViewControllerDelegate?

    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var rate : UILabel!
    @IBOutlet weak var profileDescription : UIWebView!

    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var unfavoriteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let shadowPath = UIBezierPath(rect: view.bounds)
        view.layer.shadowPath = shadowPath.CGPath
        view.layer.masksToBounds = true
        view.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5

        view.layer.cornerRadius = 10

        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.contactButton.setTitle(NSLocalizedString("Contactar", comment: ""), forState: .Normal)
        unfavoriteButton.setFAIcon(.FAStar, forState: .Normal)

        self.name?.text = professional?.name
        self.titleLabel.attributedText = self.getMutableStringWithHighlightedText((professional?.title)!)

        if(professional?.type == "S") {
            self.rate?.textColor = UIColor.serviceGreen()
            self.rate?.text = "\((professional?.rate)!) €"
        } else if (professional?.type == "H") {
            self.rate?.textColor = UIColor.perHourBlue()
            self.rate?.text = "\((professional?.rate)!) €/h"
        }

        do {
            let url = NSBundle.mainBundle().pathForResource("profileDescription", ofType:"html")
            let templateHTML = try String(contentsOfFile: url!)
            let finalHTML = templateHTML.stringByReplacingOccurrencesOfString("{{text}}", withString: (professional?.description)!)
            self.profileDescription?.loadHTMLString(finalHTML, baseURL: nil)
        } catch {
            print(error)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.avatar.hnk_setImageFromURL(NSURL(string: (professional?.avatarURL)!)!)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.viewControllerWasDismissed()
    }

    private func getMutableStringWithHighlightedText(string: String) -> NSMutableAttributedString {
        let hightlightedString = NSMutableAttributedString(string: string)

        let range = (string as NSString).rangeOfString("<highlight>(.*?)</highlight>", options:.RegularExpressionSearch)
        hightlightedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: range)
        hightlightedString.mutableString.replaceOccurrencesOfString("<highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))
        hightlightedString.mutableString.replaceOccurrencesOfString("</highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))

        return hightlightedString
    }
}

//MARK: - Actions
extension FavoriteModalViewController {
    @IBAction func contactProfessional(sender: AnyObject) {
        let string_id = professional!.string_id

        API.sharedInstance.privateInfoFor(string_id!)
        API.sharedInstance.delegate = self
    }

    @IBAction func unfavorite(sender: AnyObject) {
        Favorites.appendOrRemove(professional!)
        if Favorites.isFavorite(professional!) {
            unfavoriteButton.setFAIcon(.FAStar, forState: .Normal)
            return
        }
        unfavoriteButton.setFAIcon(.FAStarO, forState: .Normal)
    }
}

//MARK: - APIReplyDelegate
extension FavoriteModalViewController:APIReplyDelegate {
    func returnPrivateInfo(privateInfo: PrivateInfo) {
        let string = NSLocalizedString("Entre imediatamante em contacto com este profissional através do número:", comment: "")
        let alertController = UIAlertController(title: NSLocalizedString("Contactar este profissional", comment:""), message: "\(string)\n\(privateInfo.phone!)", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: NSLocalizedString("Telefonar", comment:""), style: .Default) { (action) in
            let phone = "tel://\(privateInfo.phone!)"
            let open = NSURL(string: phone)!

            UIApplication.sharedApplication().openURL(open)
        }
        alertController.addAction(OKAction)

        let SMSAction = UIAlertAction(title: NSLocalizedString("Enviar SMS", comment:""), style: .Default) { (action) in
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "";
            messageVC.recipients = [privateInfo.phone!]
            messageVC.messageComposeDelegate = self;

            self.presentViewController(messageVC, animated: true, completion: nil)
        }
        alertController.addAction(SMSAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
