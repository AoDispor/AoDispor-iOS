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
        //TODO mostrar cartões vazios no fim

        // como os indices começam no zero, o último é igual ao count
        if(index == UInt(self.cardsToExplore.count)) {
            let lastCard = NSBundle.mainBundle().loadNibNamed("LastCard", owner: self, options: nil)[0] as? LastCard
            return lastCard!
        }

        let professionalCard = NSBundle.mainBundle().loadNibNamed("ProfessionalCardNew", owner: self, options: nil)[0] as? ProfessionalCard
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
        // TODO era fixe dar para voltar para trás de uma forma mais fixe...
        if(direction == .Right) {
            koloda.revertAction()
        }
    }

    func koloda(koloda: KolodaView, didShowCardAtIndex index: UInt) {}

    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {}
}