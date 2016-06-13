//
//  Resources+Extensions.swift
//  Ao Dispor
//
//  Created by André Lamelas on 01/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import Foundation
import UIKit

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

    static func favoritYellow() -> UIColor {
        return UIColor(red:0.96, green:0.93, blue:0.28, alpha:1.0);
    }
}

class MarginLabel:UILabel {
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}