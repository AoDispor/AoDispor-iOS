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

    @IBOutlet weak var location : UILabel!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var rate : UILabel!
    @IBOutlet weak var profileDescription : UIWebView!

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

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FavoriteModalViewController.contactProfessional))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.location?.text = professional?.location
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

            let tapCatcher = UITapGestureRecognizer(target: self, action: #selector(CardExplorerViewController.recognizeTap))
            tapCatcher.numberOfTapsRequired = 1
            tapCatcher.numberOfTouchesRequired = 1
            tapCatcher.delegate = self
            self.profileDescription?.addGestureRecognizer(tapCatcher)
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

    func recognizeTap() {
        self.contactProfessional(self)
    }
}

//MARK: - Actions
extension FavoriteModalViewController {
    @IBAction func contactProfessional(sender: AnyObject) {
        let contactAlertViewController = ContactAlertViewController(professional: self.professional!, viewController: self)
        contactAlertViewController.showContactAlertViewController()
    }
}


//MARK: - UIWebViewDelegate
extension FavoriteModalViewController:UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSizeZero)
    }
}


//MARK: - UIViewControllerTransitioningDelegate
extension FavoriteModalViewController:UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return FavoritePresentationViewController(presentedViewController: presented, presentingViewController: self)
    }
}

//MARK: - DismissedViewControllerDelegate
extension FavoriteModalViewController:DismissedViewControllerDelegate {
    func viewControllerWasDismissed() {
        return
    }
}

//MARK: - UIGestureRecognizerDelegate
extension FavoriteModalViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
