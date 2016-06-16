//
//  FavoritesViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FavoritesViewController:UICollectionViewController {
    var favorites:Array<Professional> = []
    var selected = Professional()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.emptyDataSetSource = self;
        self.collectionView!.emptyDataSetDelegate = self;

        self.collectionView!.backgroundColor = UIColor.clearColor()
        self.view.setImageViewAsBackground("Background")

        self.navigationItem.title = NSLocalizedString("Favoritos", comment:"")
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoriteViewCell
        let favorite = favorites[indexPath.row]

        cell.fillWithData(favorite)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selected = favorites[indexPath.row]
        self.performSegueWithIdentifier("showModalFavorite", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let modalViewController = segue.destinationViewController as! FavoriteModalViewController
        modalViewController.transitioningDelegate = self
        modalViewController.modalPresentationStyle = .Custom
        modalViewController.professional = self.selected
    }
}

extension FavoritesViewController:DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        return  NSAttributedString(string: NSLocalizedString("Ainda não marcou nenhum profissional como favorito.", comment:""), attributes: attributes)
    }

    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                          NSBackgroundColorAttributeName: UIColor.perHourBlue()]
        return NSAttributedString(string: NSLocalizedString("Comece a adicionar favoritos", comment:""), attributes: attributes)
    }
}

extension FavoritesViewController:DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        if (self.favorites.count == 0) {
            return true
        }
        return false
    }

    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension FavoritesViewController:UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return FavoritePresentationViewController(presentedViewController: presented, presentingViewController: self)
    }
}
