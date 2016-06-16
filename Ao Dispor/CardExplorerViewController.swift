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

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 1
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class CardExplorerViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!

    var cardsToExplore:Array<Professional> = []

    var allowedDirections = [SwipeResultDirection.Left, SwipeResultDirection.Right]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.setImageViewAsBackground("Background")

        // Do any additional setup after loading the view, typically from a nib.
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        //kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - KolodaViewDataSource
extension CardExplorerViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return self.cardsToExplore.count == 0 ? 0 : UInt(self.cardsToExplore.count)+1
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        if(index == UInt(self.cardsToExplore.count)) {
            let lastCard = NSBundle.mainBundle().loadNibNamed("LastCard", owner: self, options: nil)[0] as? LastCard
            return lastCard!
        }

        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCard", owner: self, options: nil)[0] as? ProfessionalCard

        if(Int(index) > cardsToExplore.count) {
            koloda.reloadData()
        }

        let professional = cardsToExplore[Int(index)]

        professionalCard?.fillWithData(professional)

        return professionalCard!
    }
}

//MARK: - KolodaViewDelegate
extension CardExplorerViewController: KolodaViewDelegate {
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return self.allowedDirections
    }

    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        return koloda.resetCurrentCardIndex()
    }

    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        if(direction == .Right) {
            koloda.revertAction()
        }
    }
}