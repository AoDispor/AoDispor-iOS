//
//  Recursos+Extensões.swift
//  Ao Dispor
//
//  Created by André Lamelas on 24/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SwiftyButton

extension UIColor {
    //cores do aodispor
    /*
     00A8C6 - azul do título
     40C0CB
     F9F2E7 - creme claro
     AEE239 - verde mais claro
     8FBE00 - verde do rate
     */

    static var titleBlue: UIColor { return UIColor(red:0.00, green:0.66, blue:0.78, alpha:1.0) }
    static var serviceGreen: UIColor { return  UIColor(red:0.56, green:0.75, blue:0.00, alpha:1.0) }
    static var perHourBlue: UIColor { return UIColor(red:0.25, green:0.75, blue:0.80, alpha:1.0) }
    static var favoriteYellow: UIColor { return UIColor(red:0.96, green:0.93, blue:0.28, alpha:1.0) }
}

class MarginLabel: UILabel {
    var insetTop: CGFloat = 0
    var insetLeft: CGFloat = 5
    var insetBottom: CGFloat = 0
    var insetRight: CGFloat = 5

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: insetTop, left: insetLeft, bottom: insetBottom, right: insetRight)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    var UTF8EncodedData: NSData {
        return self.data(using: String.Encoding.utf8)! as NSData
    }

    func getMutableStringWithHighlightedText() -> NSMutableAttributedString {
        let hightlightedString = NSMutableAttributedString(string: self)

        let range = (self as NSString).range(of: "<highlight>(.*?)</highlight>", options:.regularExpression)
        hightlightedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: range)
        hightlightedString.mutableString.replaceOccurrences(of: "<highlight>", with: "", options: [], range: NSRange(location: 0, length: hightlightedString.mutableString.length))
        hightlightedString.mutableString.replaceOccurrences(of: "</highlight>", with: "", options: [], range: NSRange(location: 0, length: hightlightedString.mutableString.length))

        return hightlightedString
    }
}

extension Int {
    var f: CGFloat { return CGFloat(self) }
}

extension Float {
    var f: CGFloat { return CGFloat(self) }
}

extension Double {
    var f: CGFloat { return CGFloat(self) }
}

extension CGFloat {
    var swf: Float { return Float(self) }
}

extension UIView {
    func setImageViewAsBackground(named: String) {
        // veio daqui http://stackoverflow.com/a/32997867
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: named)
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill

        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }
}

public typealias PXColor = UIColor

extension PXColor {

    func lighter(amount: CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(amount: 1 + amount)
    }

    func darker(amount: CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(amount: 1 - amount)
    }

    private func hueColorWithBrightnessAmount(amount: CGFloat) -> PXColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return PXColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness * amount,
                            alpha: alpha )
        } else {
            return self
        }
    }
}

extension UIButton {
    func animateBackgroundToColor(color: UIColor, duration: TimeInterval) {
        let originalBackgroundColor = self.backgroundColor
        self.backgroundColor = color
        UIView.animate(withDuration: duration) {
            self.backgroundColor = originalBackgroundColor
        }
    }
}

/*extension UIImage {
 func cropToBounds(width: Double, height: Double) -> UIImage {
 let contextImage: UIImage = UIImage(CGImage: self.CGImage!)
 let contextSize: CGSize = contextImage.size

 var posX: CGFloat = 0.0
 var posY: CGFloat = 0.0
 var cgwidth: CGFloat = CGFloat(width)
 var cgheight: CGFloat = CGFloat(height)

 // See what size is longer and create the center off of that
 if contextSize.width > contextSize.height {
 posX = ((contextSize.width - contextSize.height) / 2)
 posY = 0
 cgwidth = contextSize.height
 cgheight = contextSize.height
 } else {
 posX = 0
 posY = ((contextSize.height - contextSize.width) / 2)
 cgwidth = contextSize.width
 cgheight = contextSize.width
 }

 let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)

 // Create bitmap image from context using the rect
 let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage!, rect)!

 // Create a new image based on the imageRef and rotate back to the original orientation
 let croppedImage: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

 return croppedImage
 }
 }*/

class BotãoAoDispor: PressableButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        definirEstilo()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        definirEstilo()
    }

    func definirEstilo() {
        self.colors = .init(
            button: UIColor.white,
            shadow: UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        )
    }
}
