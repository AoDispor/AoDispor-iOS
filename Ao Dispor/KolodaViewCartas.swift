//
//  KolodaViewCartas.swift
//  Ao Dispor
//
//  Created by André Lamelas on 24/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Koloda

let defaultTopOffset:CGFloat = 0
let defaultHorizontalOffset:CGFloat = 20
let defaultHeightRatio:CGFloat = 1.6

class KolodaViewCartas: KolodaView {
     override func frameForCard(at index: Int) -> CGRect {
        let topOffset:CGFloat = defaultTopOffset
        let xOffset:CGFloat = defaultHorizontalOffset
        let width = self.frame.width - 2 * defaultHorizontalOffset
        let height = width * defaultHeightRatio
        let yOffset:CGFloat = topOffset

        switch index {
        case 1000:
            return CGRect(x: xOffset-width, y: yOffset, width: width, height: height)
        case 0:
            return CGRect(x: xOffset, y: yOffset, width: width, height: height)
        case 1:
            return CGRect(x: xOffset+10, y: yOffset+5, width: width, height: height)
        case 2:
            return CGRect(x: xOffset+20, y: yOffset+10, width: width, height: height)
        case 3:
            return CGRect(x: xOffset+30, y: yOffset+15, width: width, height: height)
        default:
            return CGRect.zero
        }
    }
}

