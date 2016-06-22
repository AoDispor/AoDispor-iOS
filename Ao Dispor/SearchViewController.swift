//
//  SearchViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 08/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import Pulsator
import CoreLocation
import PermissionScope
import SwiftLocation

enum Action {
    case NextPage
    case ResetSearch
    case Search(query: String)
}

private let radarAnimationDuration = Int64(2) //2 segundos
private let iconWidth:Float = 46.0
private let iconHeight:Float = 34.0

class SearchViewController:UIViewController {
    static var action:Action = .ResetSearch

    var appearedAt : CFAbsoluteTime?

    let pulsator = Pulsator()
    let pscope = PermissionScope()

    var professionals:[Professional]?
    var meta:PaginatedReplyMeta?

    override func viewDidLoad() {
        super.viewDidLoad()


        let loadingText = UILabel()
        loadingText.text = NSLocalizedString("Estamos a procurar profissionais à sua volta", comment: "")
        loadingText.sizeToFit()
        loadingText.numberOfLines = 2
        loadingText.textAlignment = .Center
        loadingText.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 50)
        loadingText.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.25)
        self.view.addSubview(loadingText)

        pscope.addPermission(LocationWhileInUsePermission(),
                             message: NSLocalizedString("Para lhe mostrarmos profissionais perto de si.", comment:""))
        pscope.headerLabel.text = NSLocalizedString("Atenção!", comment:"")
        pscope.bodyLabel.text = NSLocalizedString("Precisamos de aceder à sua localização.", comment:"")

        pulsator.numPulse = 6
        pulsator.radius = 320
        pulsator.animationDuration = 6
        pulsator.backgroundColor = UIColor.titleBlue().CGColor
        pulsator.position = CGPoint(x: view.frame.width/2,  y: view.frame.height/2)
        view.layer.addSublayer(pulsator)
    }

    override func viewWillAppear(animated: Bool) {
        API.sharedInstance.delegate = self

        pulsator.start()

        pscope.show({ (finished, results) in
            switch results.first!.status {
            case .Unknown:
                self.pscope.requestLocationInUse()
            case .Unauthorized, .Disabled:
                self.executeAction()
            case .Authorized:
                self.getCoordinates()
            }
            }, cancelled: { (results) -> Void in
                self.executeAction()
        })
    }

    override func viewDidAppear(animated: Bool) {
        appearedAt = CFAbsoluteTimeGetCurrent()
    }
}

// MARK: - Search state management
extension SearchViewController {
    func executeAction() {
        switch SearchViewController.action {
        case .NextPage:
            self.loadNextPage()
        case .ResetSearch:
            self.resetSearch()
        case .Search(let query):
            self.searchFor(query)
        }
    }
    func loadNextPage() {
        let nextPage = API.sharedInstance.searchData.page + 1
        self.loadPage(nextPage)
    }

    func loadPage(page: Int) {
        API.sharedInstance.searchData.page = page
        API.sharedInstance.search()
    }

    func resetSearch() {
        API.sharedInstance.searchData.query = ""
        API.sharedInstance.searchData.page = 0
        self.loadNextPage()
    }

    func searchFor(query:String) {
        API.sharedInstance.searchData.query = query
        API.sharedInstance.searchData.page = 0
        self.loadNextPage()
    }
}

extension SearchViewController {
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCardExplorer" {
            let controller = segue.destinationViewController as! MasterViewController
            controller.cardsToExplore = professionals!
            controller.hasMorePages = meta!.hasMorePages()
            controller.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
}

extension SearchViewController {
    func getCoordinates() {
        LocationManager.shared.observeLocations(.Neighborhood, frequency: .OneShot, onSuccess: { location in
            API.sharedInstance.searchData.lat = location.coordinate.latitude
            API.sharedInstance.searchData.lon = location.coordinate.longitude
            self.executeAction()
        }) { error in
            print(error)
            self.executeAction()
        }
    }
}

//MARK: - SearchReplyDelegate
extension SearchViewController:APIReplyDelegate {
    func returnProfessionals(professionals: [Professional], meta: PaginatedReplyMeta) {
        // FIXME isto devia chamar o segue
        self.professionals = professionals
        self.meta = meta

        // FIXME guardei o timestamp de quando o VC apareceu e agora vou ver se vale a pena dormir ou não
        let elapsedTime = CFAbsoluteTimeGetCurrent() - appearedAt!
        print(elapsedTime)
        if elapsedTime > 2 {
            self.performSegueWithIdentifier("showCardExplorer", sender: self)
            return
        }

        //isto veio daqui e é feio: http://stackoverflow.com/questions/27517632/how-to-create-a-delay-in-swift
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(elapsedTime) - radarAnimationDuration * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("showCardExplorer", sender: self)
        }
    }
}
