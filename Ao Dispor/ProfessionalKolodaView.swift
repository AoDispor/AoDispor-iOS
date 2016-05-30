//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

let defaultBottomOffset:CGFloat = 0
let defaultTopOffset:CGFloat = 0
let defaultHorizontalOffset:CGFloat = 30
let defaultHeightRatio:CGFloat = 1.5

class ProfessionalKolodaView: KolodaView {

    override func frameForCardAtIndex(index: UInt) -> CGRect {
        let topOffset:CGFloat = defaultTopOffset
        let xOffset:CGFloat = defaultHorizontalOffset
        let width = CGRectGetWidth(self.frame) - 2 * defaultHorizontalOffset
        let height = width * defaultHeightRatio
        let yOffset:CGFloat = topOffset
        let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        return frame
    }
}
