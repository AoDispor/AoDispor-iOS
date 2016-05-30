	//
//  ViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 13/05/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import Koloda
import Alamofire
import AlamofireImage
import Arrow
import CoreLocation

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 1
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

private let endPercentage = 0.8


extension UIColor {
    //cores do aodispor
    /*
     00A8C6 - azul do título
     40C0CB
     F9F2E7 - creme claro
     AEE239 - verde mais claro
     8FBE00 - verde do rate
     */

    static func titleBlue() -> UIColor {
        return UIColor(red:0.00, green:0.66, blue:0.78, alpha:1.0)
    }

    static func serviceGreen() -> UIColor {
        return  UIColor(red:0.56, green:0.75, blue:0.00, alpha:1.0)
    }

    static func perHourBlue() -> UIColor {
        return UIColor(red:0.25, green:0.75, blue:0.80, alpha:1.0)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!

    var professionals = Array<Professional>()
    var loadMoreCutoff:Int = 0

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        //kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)

        self.searchBar.delegate = self

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 50 // Will notify the LocationManager every 100 meters
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }

        self.loadNextPage()
    }

    override func viewDidAppear(animated: Bool) {
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "DancingScriptOT", size: 36)!, NSForegroundColorAttributeName: UIColor.titleBlue() ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func contactProfessional() {
        self.kolodaView.swipe(.Right)
    }

    @IBAction func ignoreCard() {
        self.kolodaView.swipe(.Left)
    }

    func showDialogScreen() {
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
    }

    func loadNextPage() {
        let nextPage = API.sharedInstance.searchData.page + 1
        self.loadPage(nextPage)
    }

    func loadPage(page: Int) {
        API.sharedInstance.searchData.page = page
        API.sharedInstance.search().then { paginatedReply in
            paginatedReply.data.forEach { professional in
                self.professionals.append(professional)
            }
            if(API.sharedInstance.searchData.page == 1) {
                self.loadMoreCutoff = Int(Double(paginatedReply.meta.per_page) * endPercentage)
            }
            self.kolodaView.reloadData()
        }

    }
}

//MARK: UITextViewDelegate
extension ViewController:UITextViewDelegate {
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

}

//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
     func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        self.professionals = Array<Professional>()

        API.sharedInstance.searchData = SearchData()
        API.sharedInstance.searchData.lat = locValue.latitude
        API.sharedInstance.searchData.lon = locValue.longitude
        API.sharedInstance.searchData.query = searchBar.text!
        API.sharedInstance.searchData.page = 0

        self.loadNextPage()
    }
}

//MARK: KolodaViewDataSource
extension ViewController: KolodaViewDataSource {

    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(self.professionals.count)
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        //if almost done, load the next page
        if(index >= UInt(self.loadMoreCutoff)) {
            self.loadMoreCutoff += API.sharedInstance.searchData.per_page
            loadNextPage()
        }

        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCard", owner: self, options: nil)[0] as? ProfessionalCard
        let professional = professionals[Int(index)]

        professionalCard?.avatar.af_setImageWithURL(NSURL(string: professional.avatarURL)!)
        professionalCard?.name?.text = professional.name
        professionalCard?.title?.text = professional.title
        if(professional.type == "S") {
            professionalCard?.rate?.backgroundColor = UIColor.serviceGreen()
            professionalCard?.rate?.text = "\(professional.rate) €"
        } else if (professional.type == "H") {
            professionalCard?.rate?.backgroundColor = UIColor.perHourBlue()
            professionalCard?.rate?.text = "\(professional.rate) €/h"
        }

        professionalCard?.profileDescription?.loadHTMLString(professional.description, baseURL: nil)
        professionalCard?.delegate = self
        
        return professionalCard!
    }

    /*func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }*/
}

//MARK: UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
}

//MARK: UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.professionals = Array<Professional>()

        API.sharedInstance.searchData = SearchData()
        API.sharedInstance.searchData.query = searchBar.text!
        API.sharedInstance.searchData.page = 0

        searchBar.endEditing(true)

        self.loadNextPage()
    }
}

//MARK: KolodaViewDelegate
extension ViewController: KolodaViewDelegate {
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [SwipeResultDirection.Left, SwipeResultDirection.Right]
    }

    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        print(index)
    }

    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        switch direction {
        case .Right:
            self.showDialogScreen()
        default:
            return;
        }
    }
}