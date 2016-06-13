//
//  SearchViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 08/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit

class SearchViewController:UIViewController {
    var searchBar: UISearchBar!
    var locationBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let w = self.view.frame.width

        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: w, height: 44))
        locationBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: w, height: 44))

        let stackView = UIStackView(arrangedSubviews: [searchBar, locationBar])
        self.view.addSubview(stackView)
    }
}