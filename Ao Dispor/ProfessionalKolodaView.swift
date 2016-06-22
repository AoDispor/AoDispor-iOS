//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

let defaultTopOffset:CGFloat = 0
let defaultHorizontalOffset:CGFloat = 20
let defaultHeightRatio:CGFloat = 1.6

class ProfessionalKolodaView: KolodaView {
    override func frameForCardAtIndex(index: UInt) -> CGRect {
        let topOffset:CGFloat = defaultTopOffset
        let xOffset:CGFloat = defaultHorizontalOffset
        let width = CGRectGetWidth(self.frame) - 2 * defaultHorizontalOffset
        let height = width * defaultHeightRatio
        let yOffset:CGFloat = topOffset

        switch index {
        case 0:
            return CGRect(x: xOffset, y: yOffset, width: width, height: height)
        case 1:
            return CGRect(x: xOffset+10, y: yOffset+5, width: width, height: height)
        case 2:
            return CGRect(x: xOffset+20, y: yOffset+10, width: width, height: height)
        default:
            return CGRectZero
        }
    }
}
