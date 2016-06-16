//
//  MasterViewController.swift
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
import PermissionScope
import CoreSpotlight
import MobileCoreServices
import MessageUI

private let endPercentage = 0.8

class MasterViewController: CardExplorerViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    var favorites = Array<Professional>()

    var loadMoreCutoff:Int = 0
    var waiting = false

    let locationManager = CLLocationManager()
    let pscope = PermissionScope()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("De quem precisa?", comment: "")

        pscope.addPermission(LocationWhileInUsePermission(),
                             message: NSLocalizedString("Para lhe mostrarmos profissionais perto de si.", comment:""))
        pscope.headerLabel.text = NSLocalizedString("Atenção!", comment:"")
        pscope.bodyLabel.text = NSLocalizedString("Precisamos de aceder à sua localização.", comment:"")
        pscope.show({ finished, results in
                self.startupdatingLocationManager()
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })

        self.startupdatingLocationManager()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let titleView = UILabel()
        titleView.text = "Ao Dispor"
        titleView.font = UIFont(name: "DancingScriptOT", size: 36)!
        titleView.textColor = UIColor.titleBlue()

        let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MasterViewController.resetSearch))
        titleView.userInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)

        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!

        let rightButton = UIBarButtonItem(title: NSLocalizedString("Favoritos", comment:""), style: .Done, target: self, action: #selector(MasterViewController.showFavorites))
        rightButton.setTitleTextAttributes(attributes, forState: .Normal)
        rightButton.title = String.fontAwesomeIconWithName(.StarO)
        self.navigationItem.rightBarButtonItem = rightButton


        contactButton.setTitle(NSLocalizedString("Contactar", comment: ""), forState: .Normal)
        favoriteButton.setTitle(NSLocalizedString("Guardar", comment: ""), forState: .Normal)
        nextButton.setTitle(NSLocalizedString("Seguinte", comment: ""), forState: .Normal)

        favoriteButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        favoriteButton.setTitle(String.fontAwesomeIconWithName(.StarO), forState: .Disabled)

        self.updateFavoritesButtonStar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startupdatingLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = 50 // Will notify the LocationManager every 50 meters
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
    }

    func updateFavoritesButtonStar() {
        if(favorites.count > 0) {
            self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIconWithName(.Star)
        } else {
            self.navigationItem.rightBarButtonItem!.title = String.fontAwesomeIconWithName(.StarO)
        }
    }

    func loadNextPage() {
        let nextPage = API.sharedInstance.searchData.page + 1
        self.loadPage(nextPage)
    }

    func loadPage(page: Int) {
        if(self.waiting) {
            return
        }

        self.waiting = true;
        self.contactButton.enabled = false
        self.favoriteButton.enabled = false
        self.nextButton.enabled = false

        API.sharedInstance.searchData.page = page
        API.sharedInstance.search().then { paginatedReply in
            paginatedReply.data.forEach { professional in
                self.cardsToExplore.append(professional)
            }
            if(API.sharedInstance.searchData.page == 1) {
                self.loadMoreCutoff = Int(Double(paginatedReply.meta.perPage) * endPercentage)
            }
            self.waiting = false;
            self.contactButton.enabled = true
            self.favoriteButton.enabled = true
            self.nextButton.enabled = true

            self.kolodaView.reloadData()
        }

        self.kolodaView.reloadData()
    }

    func resetSearch() {
        self.cardsToExplore = Array<Professional>()

        API.sharedInstance.searchData.query = ""
        API.sharedInstance.searchData.page = 0

        self.searchBar.endEditing(true)
        self.searchBar.text = ""

        self.loadNextPage()
    }

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFavorites" {
            let controller = segue.destinationViewController as! FavoritesViewController
            controller.favorites = self.favorites
            controller.navigationItem.title = NSLocalizedString("Favoritos", comment:"")
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    //MARK: - Overrides
    override func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return self.cardsToExplore.count == 0 ? 0 : UInt(self.cardsToExplore.count) + 1
    }

    override func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        if(index == UInt(self.cardsToExplore.count)) {
            let lastCard = NSBundle.mainBundle().loadNibNamed("LastCard", owner: self, options: nil)[0] as? LastCard
            self.contactButton.enabled = false
            self.favoriteButton.enabled = false

            return lastCard!
        }

        self.contactButton.enabled = true
        self.favoriteButton.enabled = true

        //if almost done, load the next page
        if(index >= UInt(self.loadMoreCutoff)) {
            self.loadMoreCutoff += API.sharedInstance.searchData.perPage
            loadNextPage()
        }

        if(Int(index) > cardsToExplore.count) {
            koloda.reloadData()
        }

        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCard", owner: self, options: nil)[0] as? ProfessionalCard

        let professionalSelected = cardsToExplore[Int(index)]
        professionalCard?.fillWithData(professionalSelected)

        var starToUse = String.fontAwesomeIconWithName(.StarO)
        favorites.forEach { professional in
            if professionalSelected.string_id == professional.string_id {
                starToUse = String.fontAwesomeIconWithName(.Star)
            }
        }

        let attributed = NSAttributedString(string: starToUse, attributes: [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)])
        favoriteButton.setAttributedTitle(attributed, forState: .Normal)
        favoriteButton.setAttributedTitle(attributed, forState: .Disabled)

        return professionalCard!
    }
}

// MARK: - Button Actions
extension MasterViewController {
    @IBAction func showFavorites(sender: AnyObject) {
        performSegueWithIdentifier("showFavorites", sender: sender)
    }

    @IBAction func contactProfessional(sender: AnyObject) {
        let professional = self.cardsToExplore[self.kolodaView.currentCardIndex]
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

    @IBAction func nextProfessional(sender: AnyObject) {
        self.kolodaView.swipe(.Left)
    }

    @IBAction func markContactAsFavorite(sender: AnyObject) {
        let professionalToAdd = self.cardsToExplore[self.kolodaView.currentCardIndex]
        self.favorites.append(professionalToAdd)

        self.allowedDirections.append(SwipeResultDirection.Up)
        let originalCardSwipeActionAnimationDuration = cardSwipeActionAnimationDuration
        cardSwipeActionAnimationDuration = originalCardSwipeActionAnimationDuration * 3
        self.kolodaView.swipe(.Up)
        cardSwipeActionAnimationDuration = originalCardSwipeActionAnimationDuration
        self.allowedDirections.removeLast()

        self.updateFavoritesButtonStar()
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension MasterViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: - CLLocationManagerDelegate
extension MasterViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        self.cardsToExplore = Array<Professional>()

        //API.sharedInstance.searchData = SearchData()
        API.sharedInstance.searchData.lat = locValue.latitude
        API.sharedInstance.searchData.lon = locValue.longitude
        API.sharedInstance.searchData.query = searchBar.text!
        API.sharedInstance.searchData.page = 0

        self.loadNextPage()
    }
}

//MARK: - UISearchBarDelegate
extension MasterViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)

        self.cardsToExplore = Array<Professional>()

        API.sharedInstance.searchData.query = searchBar.text!
        API.sharedInstance.searchData.page = 0

        searchBar.endEditing(true)

        self.loadNextPage()
    }
}
