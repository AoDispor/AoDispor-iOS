//
//  CardExplorerViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import Koloda
import Alamofire
import AlamofireImage
import Arrow
import CoreLocation
import FontAwesome_swift
import MessageUI

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 1
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class CardExplorerViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!

    var cardsToExplore:Array<Professional> = []

    private var allowedDirections = [SwipeResultDirection.Left, SwipeResultDirection.Right]

    override func viewDidLoad() {
        super.viewDidLoad()

        // veio daqui http://stackoverflow.com/a/32997867
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "Background")
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill

        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)

        // Do any additional setup after loading the view, typically from a nib.
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        //kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.favoriteButton.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        self.favoriteButton.setTitle(String.fontAwesomeIconWithName(.Star), forState: .Normal)

        self.callButton.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        self.callButton.setTitle(String.fontAwesomeIconWithName(.Phone), forState: .Normal)

        self.contactButton.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        self.contactButton.setTitle(String.fontAwesomeIconWithName(.Comment), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Button Actions
extension CardExplorerViewController {
    @IBAction func callProfessional(sender: AnyObject) {
        let professional = self.cardsToExplore[self.kolodaView.currentCardIndex]
        let string_id = professional.string_id

        API.sharedInstance.telephoneFor(string_id).then { privateInfo in
            let alertController = UIAlertController(title: "Contactar este profissional", message: "Entre imediatamante en contacto com este profissional através do número:\n\(privateInfo.phone)", preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "Telefonar", style: .Default) { (action) in
                let phone = "tel://\(privateInfo.phone)"
                let open = NSURL(string: phone)!

                UIApplication.sharedApplication().openURL(open)
            }
            alertController.addAction(OKAction)

            let SMSAction = UIAlertAction(title: "Enviar SMS", style: .Default) { (action) in
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

    @IBAction func contactProfessional(sender: AnyObject) {
        API.sharedInstance.telephoneFor(self.cardsToExplore[kolodaView.currentCardIndex].string_id).then { privateInfo in
            let phone = privateInfo.phone
            let messageVC = MFMessageComposeViewController()

            messageVC.body = "";
            messageVC.recipients = [phone]
            messageVC.messageComposeDelegate = self;

            self.presentViewController(messageVC, animated: true, completion: nil)
        }
    }

    @IBAction func ignoreCard(sender: AnyObject) {
        self.kolodaView.swipe(.Left)
    }
}

//MARK: MFMessageComposeViewControllerDelegate
extension CardExplorerViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: KolodaViewDataSource
extension CardExplorerViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(self.cardsToExplore.count)
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCard", owner: self, options: nil)[0] as? ProfessionalCard
        if(Int(index) > cardsToExplore.count) {
            koloda.reloadData()
        }
        let professional = cardsToExplore[Int(index)]

        professionalCard?.fillWithData(professional)
        //professionalCard?.delegate = self

        return professionalCard!
    }
}

//MARK: KolodaViewDelegate
extension CardExplorerViewController: KolodaViewDelegate {
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return self.allowedDirections
    }

    func kolodaDidRunOutOfCards(koloda: KolodaView) {}

    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        if(direction == .Right) {
            koloda.revertAction()
        }
    }
}