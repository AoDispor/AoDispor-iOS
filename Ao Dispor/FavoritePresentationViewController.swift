//
//  FavoritePresentationViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 15/06/16.
//  Copyright © 2016 Ao Dispor. All rights reserved.
//

import UIKit

class FavoritePresentationViewController: UIPresentationController {
    var dimmingView: UIView!

    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        setupDimmingView()
    }

    func setupDimmingView() {
        dimmingView = UIView(frame: presentingViewController.view.bounds)

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
        visualEffectView.frame = dimmingView.bounds
        visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        dimmingView.addSubview(visualEffectView)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FavoritePresentationViewController.dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
    }

    func dimmingViewTapped(tapRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        let containerView = self.containerView
        let presentedViewController = self.presentedViewController

        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0

        containerView!.insertSubview(dimmingView, atIndex: 0)
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (coordinatorContext) -> Void in
            self.dimmingView.alpha = 1.0
            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (coordinatorContext) -> Void in
            self.dimmingView.alpha = 0.0
            }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView!.bounds
        presentedView()!.frame = frameOfPresentedViewInContainerView()
    }

    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSizeMake(parentSize.width * 0.8, parentSize.height * 0.8)
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView!.bounds

        let contentContainer = presentedViewController

        presentedViewFrame.size = sizeForChildContentContainer(contentContainer, withParentContainerSize: containerBounds.size) //CGSizeMake(428.0, presentedView().frame.size.height) //
        presentedViewFrame.origin.x = containerBounds.size.width * 0.1
        presentedViewFrame.origin.y = containerBounds.size.height * 0.1

        return presentedViewFrame
    }

    //return CGRect(x: 0, y: 0, width: containerView!.bounds.width/2, height: containerView!.bounds.height/2)
}
