//
//  CardExplorerViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import Koloda

private let kolodaCountOfVisibleCards = 3
private let kolodaAlphaValueSemiTransparent: CGFloat = 1

class CardExplorerViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!

    var cardsToExplore = Array<Professional>()
    var hasMorePages = false

    var allowedDirections = [SwipeResultDirection.Left, SwipeResultDirection.Right]

    override func viewDidLoad() {
        super.viewDidLoad()

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

    func getPreviousCard(sender: AnyObject) {
        if self.kolodaView.currentCardIndex == 0 {
            return
        }

        var baseIndex = UInt(self.kolodaView.currentCardIndex - 1)

        self.kolodaView.clear()
        self.kolodaView.currentCardIndex = Int(baseIndex)
        
        var cardsToAppear = [DraggableCardView]()

        // buscar e adicionar à view a carta a aparecer
        let firstCard = self.kolodaView.createCardAtIndex(baseIndex, frame: self.kolodaView.frameForCardAtIndex(1000))
        cardsToAppear.append(firstCard)
        // a carta que está em primeiro plano
        baseIndex += 1
        let secondCard = self.kolodaView.createCardAtIndex(baseIndex, frame: self.kolodaView.frameForCardAtIndex(0))
        cardsToAppear.append(secondCard)
        // a segunda
        baseIndex += 2
        let thirdCard = self.kolodaView.createCardAtIndex(baseIndex, frame: self.kolodaView.frameForCardAtIndex(1))
        cardsToAppear.append(thirdCard)
        // a terceira
        baseIndex += 3
        let fourthCard = self.kolodaView.createCardAtIndex(baseIndex, frame: self.kolodaView.frameForCardAtIndex(2))
        cardsToAppear.append(fourthCard)

        cardsToAppear.reverse().forEach { (card) in
            self.kolodaView.addSubview(card)
        }

        UIView.animateWithDuration(cardSwipeActionAnimationDuration, animations: {
            firstCard.frame = self.kolodaView.frameForCardAtIndex(0)
            secondCard.frame = self.kolodaView.frameForCardAtIndex(1)
            thirdCard.frame = self.kolodaView.frameForCardAtIndex(2)
            fourthCard.frame = self.kolodaView.frameForCardAtIndex(3)
            }, completion: { completed in
                firstCard.removeFromSuperview()
                secondCard.removeFromSuperview()
                thirdCard.removeFromSuperview()
                fourthCard.removeFromSuperview()
                self.kolodaView.reloadData()
        })
    }
}

//MARK: - KolodaViewDataSource
extension CardExplorerViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        // se tiver multiplas páginas, mostra só o número de cartões (carrega mais quando chega ao fim)
        if (hasMorePages) {
            return UInt(self.cardsToExplore.count)
        }
        // se tiver zero cartões e não tiver mais páginas, então é porque não tem resultados (0 cartões)
        if (self.cardsToExplore.isEmpty) {
            return 0
        }
        // tendo cartões e só uma página, retorna o numero de cartões mais 1 (para mostrar o final)
        return UInt(self.cardsToExplore.count)+1
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        // TODO mostrar cartões vazios no fim

        // como os indices começam no zero, o último é igual ao count
        if(index == UInt(self.cardsToExplore.count)) {
            let lastCard = NSBundle.mainBundle().loadNibNamed("LastCard", owner: self, options: nil)[0] as? LastCard
            return lastCard!
        }

        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCardNew", owner: self, options: nil)[0] as? ProfessionalCard
        let professional = cardsToExplore[Int(index)]
        
        professionalCard?.fillWithData(professional)

        let tapCatcher = UITapGestureRecognizer(target: self, action: #selector(CardExplorerViewController.recognizeTap))
        tapCatcher.numberOfTapsRequired = 1
        tapCatcher.numberOfTouchesRequired = 1
        tapCatcher.delegate = self
        professionalCard?.profileDescription?.addGestureRecognizer(tapCatcher)

        return professionalCard!
    }

    func recognizeTap() {
        self.kolodaView.delegate?.koloda(kolodaView, didSelectCardAtIndex: UInt(self.kolodaView.currentCardIndex))
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

    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return false
    }

    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {}
}

//MARK: - UIGestureRecognizerDelegate
extension CardExplorerViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

