//
//  Cartão.swift
//  Ao Dispor
//
//  Created by André Lamelas on 01/06/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

class Cartão: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.cgPath
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
