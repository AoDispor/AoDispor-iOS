//
//  Resources+Extensions.swift
//  Ao Dispor
//
//  Created by André Lamelas on 01/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

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
    var insetTop: CGFloat = 0
    var insetLeft: CGFloat = 5
    var insetBottom: CGFloat = 0
    var insetRight: CGFloat = 5

    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: insetTop, left: insetLeft, bottom: insetBottom, right: insetRight)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}

extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }

    var encodedSHA256: String {
        let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(self.asData().bytes, CC_LONG(self.asData().length), UnsafeMutablePointer(res!.mutableBytes))
        let nsString = NSString(data: res!, encoding: NSUTF8StringEncoding)
        return "\(nsString)"
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
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: named)
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill

        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}

extension UIImage {
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
}
