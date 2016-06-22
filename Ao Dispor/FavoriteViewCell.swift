//
//  FavoriteViewCell.swift
//  Ao Dispor
//
//  Created by André Lamelas on 13/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit

class FavoriteViewCell:UICollectionViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var title: UILabel!

    func fillWithData(professional: Professional) -> Void {
        self.avatar.hnk_setImageFromURL(NSURL(string: professional.avatarURL!)!)
        self.name?.text = professional.name
        self.title?.text = professional.title!.stringByReplacingOccurrencesOfString("<highlight>", withString: "").stringByReplacingOccurrencesOfString("</highlight>", withString: "")
    }
}
