//
//  IMPageContentViewController.swift
//  IMViewPager
//
//  Created by immortal on 2022/1/17
//

import UIKit

protocol IMPageContentViewControllerDelegate: AnyObject {
    
    func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        pageControllerForItemAt pageIndex: Int,
        current: IMPageController
    ) -> IMPageController?
    
    func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        didScrollWith progress: CGFloat,
        for nextPageController: IMPageController?,
        current: IMPageController
    )
    
    func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        didFinishWith pageController: IMPageController
    )
    
    func pageContentViewControllerWillDrag(_ pageContentViewController: IMPageContentViewController)

    func pageContentViewControllerDidEndDrag(_ pageContentViewController: IMPageContentViewController)
}


protocol IMPageContentViewController: UIViewController {
  
    /// The delegate object.
    ///
    /// Methods of the delegate are called in response to gesture-based navigation and orientation changes.
    var delegate: IMPageContentViewControllerDelegate? { get set }
    
    /// The direction along which navigation occurs.
    var navigationOrientation: IMPageViewController.NavigationOrientation { get set }
    
    /// The page controllers displayed by the page content view controller.
    var pageControllers: [IMPageController]? { get }

    /// Sets the view controller to be displayed.
    ///
    /// - Parameter controller:
    ///     The page controller  to be displayed.
    ///
    /// - Parameter direction:
    ///     The navigation direction.
    ///
    /// - Parameter animated:
    ///     A Boolean value that indicates whether the transition is to be animated.
    ///
    /// - Parameter completion:
    ///     A block to be called when the page-turn animation completes.
    ///     The block takes the following parameters:
    /// - Parameter finished:
    ///     `true` if the animation finished;
    ///     `false` if it was skipped.
    ///
    func setController(
        _ controller: UIViewController?,
        direction: IMPageViewController.NavigationDirection,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) 
}

extension IMPageContentViewController {
    
    var containerViewController: IMPageViewController? {
        parent as? IMPageViewController
    }
    
    typealias NavigationOrientation = IMPageViewController.NavigationOrientation

    typealias SpineLocation = IMPageViewController.SpineLocation

    typealias TransitionStyle = IMPageViewController.TransitionStyle

    typealias NavigationDirection = IMPageViewController.NavigationDirection
    
    typealias CachePolicy = IMPageViewController.CachePolicy
}
