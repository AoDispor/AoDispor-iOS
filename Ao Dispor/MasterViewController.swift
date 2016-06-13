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

private let endPercentage = 0.8

class MasterViewController: CardExplorerViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    var favorites = Array<Professional>()
    var loadMoreCutoff:Int = 0
    var waiting = false

    let locationManager = CLLocationManager()
    let pscope = PermissionScope()
    private var allowedDirections = [SwipeResultDirection.Left, SwipeResultDirection.Right]

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!

        let rightButton = UIBarButtonItem(title: "Favoritos", style: .Done, target: self, action: #selector(MasterViewController.showFavorites))
        rightButton.setTitleTextAttributes(attributes, forState: .Normal)
        rightButton.title = String.fontAwesomeIconWithName(.StarO)
        self.navigationItem.rightBarButtonItem = rightButton

        self.searchBar.delegate = self

        pscope.addPermission(LocationWhileInUsePermission(),
                             message: "Para lhe mostrarmos profissionais perto de si.")
        pscope.headerLabel.text = "Atenção!"
        pscope.bodyLabel.text = "Precisamos de aceder à sua localização."
        pscope.show({ finished, results in
                self.startupdatingLocationManager()
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })

        self.startupdatingLocationManager()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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

        /*self.navigationController?.navigationBar.topItem?.title = "Ao Dispor"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "DancingScriptOT", size: 36)!, NSForegroundColorAttributeName: UIColor.titleBlue() ]*/

        // isto veio daqui e é feio http://stackoverflow.com/a/10491149
        /*let singleTap = UITapGestureRecognizer(target: self, action: #selector(MasterViewController.resetSearch))
        self.navigationController?.navigationBar.subviews[1].userInteractionEnabled = true
        self.navigationController?.navigationBar.subviews[1].addGestureRecognizer(singleTap)*/
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

    /*func showDialogScreen() {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .Alert)

        let margin:CGFloat = 8.0
        let rect = CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0, 100.0)
        let textView = UITextView(frame: rect)

        textView.backgroundColor = UIColor.clearColor()
        textView.font = UIFont(name: "Helvetica", size: 15)
        textView.text = "Escreva aqui a sua mensagem para este profissional."
        textView.textColor = UIColor.lightGrayColor()
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        textView.delegate = self

        alertController.view.addSubview(textView)

        let somethingAction = UIAlertAction(title: "Enviar", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in print("something")
        })

        let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

        alertController.addAction(somethingAction)
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true, completion:{})
    }*/

    func loadNextPage() {
        let nextPage = API.sharedInstance.searchData.page + 1
        self.loadPage(nextPage)
    }

    func loadPage(page: Int) {
        if(self.waiting) {
            return
        }

        self.waiting = true;

        API.sharedInstance.searchData.page = page
        API.sharedInstance.search().then { paginatedReply in
            paginatedReply.data.forEach { professional in
                self.cardsToExplore.append(professional)
            }
            if(API.sharedInstance.searchData.page == 1) {
                self.loadMoreCutoff = Int(Double(paginatedReply.meta.per_page) * endPercentage)
            }
            self.waiting = false;
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
            controller.cardsToExplore = self.favorites
            controller.navigationItem.title = "Favoritos"
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    //MARK: - Overrides
    override func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        //if almost done, load the next page
        if(index >= UInt(self.loadMoreCutoff)) {
            self.loadMoreCutoff += API.sharedInstance.searchData.per_page
            loadNextPage()
        }

        let professionalCard = super.koloda(koloda, viewForCardAtIndex: index)
        return professionalCard
    }
}


// MARK: Button Actions
extension MasterViewController {
    @IBAction func showFavorites(sender: AnyObject) {
        performSegueWithIdentifier("showFavorites", sender: sender)
        //performSegueWithIdentifier("collectionView", sender: sender)
        /*let vc = SearchViewController()
        self.navigationController?.pushViewController(vc, animated: true)*/
    }

    @IBAction func markContactAsFavorite(sender: AnyObject) {
        if(self.kolodaView.currentCardIndex > self.cardsToExplore.count) {
            return;
        }

        let professionalToAdd = self.cardsToExplore[self.kolodaView.currentCardIndex]
        self.favorites.append(professionalToAdd)

        self.allowedDirections.append(SwipeResultDirection.Up)
        let originalCardSwipeActionAnimationDuration = cardSwipeActionAnimationDuration
        cardSwipeActionAnimationDuration = originalCardSwipeActionAnimationDuration * 3
        self.kolodaView.swipe(.Up)
        cardSwipeActionAnimationDuration = originalCardSwipeActionAnimationDuration
        self.allowedDirections.removeLast()
    }
}


//MARK: UITextViewDelegate
/*extension MasterViewController:UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = "Escreva aqui a sua mensagem para este profissional."
            textView.textColor = UIColor.lightGrayColor()

            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)

            return false
        }

            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }

        return true
    }

    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }

}*/

//MARK: CLLocationManagerDelegate
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

//MARK: UISearchBarDelegate
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
