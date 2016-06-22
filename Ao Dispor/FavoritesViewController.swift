//
//  FavoritesViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 02/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol DismissedViewControllerDelegate {
    func viewControllerWasDismissed()
}

class FavoritesViewController:UICollectionViewController {
    var selected:Professional?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.emptyDataSetSource = self;
        self.collectionView!.emptyDataSetDelegate = self;

        self.collectionView!.backgroundColor = UIColor.whiteColor()
        //self.collectionView!.backgroundColor = UIColor.clearColor()
        //self.view.setImageViewAsBackground("Background")

        self.navigationItem.title = NSLocalizedString("Favoritos", comment:"")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
            self.collectionView?.reloadEmptyDataSet()
        });
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Favorites.numberOfFavorites()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoriteViewCell
        let favorite = Favorites.favoriteAtIndex(indexPath.row)

        cell.fillWithData(favorite)

        let shadowPath = UIBezierPath(rect: cell.bounds)
        cell.layer.shadowPath = shadowPath.CGPath
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOpacity = 0.5

        cell.layer.cornerRadius = 10

        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blackColor().CGColor

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selected = Favorites.favoriteAtIndex(indexPath.row)
        self.performSegueWithIdentifier("showModalFavorite", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let modalViewController = segue.destinationViewController as! FavoriteModalViewController
        modalViewController.transitioningDelegate = self
        modalViewController.delegate = self
        modalViewController.modalPresentationStyle = .Custom
        modalViewController.professional = self.selected
    }
}

//MARK: - DZNEmptyDataSetSource
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

//MARK: - DZNEmptyDataSetDelegate
extension FavoritesViewController:DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return Favorites.numberOfFavorites() == 0
    }

    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension FavoritesViewController:UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return FavoritePresentationViewController(presentedViewController: presented, presentingViewController: self)
    }
}

//MARK: - DismissedViewControllerDelegate
extension FavoritesViewController:DismissedViewControllerDelegate {
    func viewControllerWasDismissed() {
        self.collectionView?.reloadData()
    }
}
