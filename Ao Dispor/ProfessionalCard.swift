//
//  ProfessionalCard.swift
//  Ao Dispor
//
//  Created by André Lamelas on 16/05/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit

class ProfessionalCard: UIView {
    var professional:Professional?

    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var rate : UILabel!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var profileDescription : UIWebView!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var location : UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.CGPath
        layer.masksToBounds = false
        layer.shadowOffset = CGSizeMake(5.0, 5.0)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.5

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
    }

    func fillWithData(professional: Professional) -> Void {
        self.professional = professional

        self.avatar.hnk_setImageFromURL(NSURL(string: professional.avatarURL!)!)
        self.title.attributedText = self.getMutableStringWithHighlightedText(professional.title!)
        self.name?.text = professional.name
        self.location?.text = professional.location
        self.location?.sizeToFit()

        if(professional.type == "S") {
            self.rate?.textColor = UIColor.serviceGreen()
            self.rate?.text = "\(professional.rate!) €"
        } else if (professional.type == "H") {
            self.rate?.textColor = UIColor.perHourBlue()
            self.rate?.text = "\(professional.rate!) €/h"
        }

        do {
            let url = NSBundle.mainBundle().pathForResource("profileDescription", ofType:"html")
            let templateHTML = try String(contentsOfFile: url!)
            let finalHTML = templateHTML.stringByReplacingOccurrencesOfString("{{text}}", withString: professional.description!)
            self.profileDescription?.loadHTMLString(finalHTML, baseURL: nil)
            self.profileDescription?.dataDetectorTypes = .None
        } catch {
            print(error)
        }
    }

    private func getMutableStringWithHighlightedText(string: String) -> NSMutableAttributedString {
        let hightlightedString = NSMutableAttributedString(string: string)

        let range = (string as NSString).rangeOfString("<highlight>(.*?)</highlight>", options:.RegularExpressionSearch)
        hightlightedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: range)
        hightlightedString.mutableString.replaceOccurrencesOfString("<highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))
        hightlightedString.mutableString.replaceOccurrencesOfString("</highlight>", withString: "", options: [], range: NSMakeRange(0, hightlightedString.mutableString.length))

        return hightlightedString
    }
}
