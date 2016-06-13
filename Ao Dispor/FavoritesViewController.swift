//
//  FavoritesViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import Koloda

class FavoritesViewController:CardExplorerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kolodaView.delegate = self
    }

    override func kolodaDidRunOutOfCards(koloda: KolodaView) {
        koloda.resetCurrentCardIndex()
    }
}