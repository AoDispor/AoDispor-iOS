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
}

extension ProfessionalCard:UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSizeZero)
        
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