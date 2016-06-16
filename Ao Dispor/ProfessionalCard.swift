//
//  ProfessionalCard.swift
//  Ao Dispor
//
//  Created by André Lamelas on 16/05/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit

class ProfessionalCard: UIScrollView {
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var rate : UILabel!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var profileDescription : UIWebView!
    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var location : UILabel!

    var shouldShowFullDescription = true

    func fillWithData(professional: Professional) -> Void {
        self.avatar.af_setImageWithURL(NSURL(string: professional.avatarURL)!)
        self.name?.text = professional.name
        self.title.attributedText = self.getMutableStringWithHighlightedText(professional.title)
        self.location?.text = professional.location
        self.location?.sizeToFit()

        if(professional.type == "S") {
            self.rate?.textColor = UIColor.serviceGreen()
            self.rate?.text = "\(professional.rate) €"
        } else if (professional.type == "H") {
            self.rate?.textColor = UIColor.perHourBlue()
            self.rate?.text = "\(professional.rate) €/h"
        }

        do {
            let url = NSBundle.mainBundle().pathForResource("profileDescription", ofType:"html")
            let templateHTML = try String(contentsOfFile: url!)
            let finalHTML = templateHTML.stringByReplacingOccurrencesOfString("{{text}}", withString: professional.description)
            self.profileDescription?.loadHTMLString(finalHTML, baseURL: nil)
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

extension ProfessionalCard:UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSizeZero)

        if(!shouldShowFullDescription) {
            return
        }

        let originalWidth = self.frame.width

        var contentRect = CGRectZero
        self.subviews.forEach { view in
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        contentRect = CGRectUnion(contentRect, profileDescription.frame)
        contentRect.size.width = originalWidth

        self.contentSize = contentRect.size
    }
}