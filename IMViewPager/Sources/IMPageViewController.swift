//
//  IMPageViewController.swift
//  IMViewPager
//
//  Created by immortal on 2021/8/9
//

import UIKit

/// The PageViewControllerDataSource protocol is adopted by an object that provides view controllers to the page view controller on an as-needed basis, in response to navigation gestures.
public protocol IMPageViewControllerDataSource: AnyObject {

    /// Returns the view controller before the given view controller.
    ///
    /// - Parameter pageViewController:
    ///     The page view controller.
    ///
    /// - Parameter viewController:
    ///     The view controller that the user navigated away from.
    ///
    /// - Returns:
    ///     The view controller before the given view controller, or nil to indicate that there is no previous view controller.
    ///
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?

    /// Returns the view controller after the given view controller.
    ///
    /// - Parameter pageViewController:
    ///     The page view controller.
    ///
    /// - Parameter viewController:
    ///     The view controller that the user navigated away from.
    ///
    /// - Returns:
    ///     The view controller after the given view controller, or nil to indicate that there is no next view controller.
    ///
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    
    /// Called after the cached controller's view is displayed.
    ///
    /// - Parameter pageViewController:
    ///     The page view controller.
    ///
    /// - Parameter cachedViewController:
    ///     The cached view controller to be displayed.
    ///
    func pageViewController(_ pageViewController: IMPageViewController, didConfigure cachedViewController: UIViewController)
}

public extension IMPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        nil
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, didConfigure cachedViewController: UIViewController) {}
}

/// The delegate of a page view controller must adopt the PageViewControllerDelegate protocol.
/// These methods allow the delegate to receive a notification when the device orientation changes and when the user navigates to a new page.
public protocol IMPageViewControllerDelegate: AnyObject {

    /// Called after the replace is finished.
    ///
    /// - Parameter pageViewController:
    ///     The page view controller.
    ///
    /// - Parameter viewController:
    ///     The current visible view controller.
    ///
    func pageViewController(_ pageViewController: IMPageViewController, didFinishWith viewController: UIViewController)
   
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollWith progress: CGFloat,
        for nextViewController: UIViewController?,
        current currentViewController: UIViewController
    )
    
    func pageViewControllerWillDrag(_ pageViewController: IMPageViewController)

    func pageViewControllerDidEndDrag(_ currentController: IMPageViewController)
}

public extension IMPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: IMPageViewController,
        didFinishWith viewController: UIViewController
    ) {}
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollWith progress: CGFloat,
        for nextViewController: UIViewController?,
        current currentViewController: UIViewController
    ) {}
    
    func pageViewControllerWillDrag(_ pageViewController: IMPageViewController) {}

    func pageViewControllerDidEndDrag(_ currentController: IMPageViewController) {}
}


/// A container view controller that manages navigation between pages of content, where a child view controller manages each page.
///
/// Page view controller–navigation can be controlled programmatically by your app or directly by the user using gestures.
/// When navigating from page to page, the page view controller uses the transition that you specify to animate the change.
@available(iOS 9.0, *)
open class IMPageViewController: UIViewController, IMPageContentViewControllerDelegate {
     
    /// Orientations for page-turn transitions.
    public enum NavigationOrientation: Int {

        /// Horizontal orientation, with pages turning left and right.
        case horizontal

        /// Vertical orientation, with pages turning up and down.
        case vertical
    }

    /// Locations for the spine.
    public enum SpineLocation: CGFloat {

        /// Spine at the left or top edge of the screen.
        ///
        /// Requires one view controller.
        case lower = -2.0

        /// Spine at the left or top edge of the screen.
        ///
        /// Requires one view controller.
        case min = -1.0

        /// Spine in the middle or the screen.
        ///
        /// Requires two view controllers.
        case mid = 0.0

        /// Spine at the right or bottom edge of the screen.
        ///
        /// Requires one view controller.
        case max = 1.0

        /// Spine at the right or bottom edge of the screen.
        ///
        /// Requires one view controller.
        case upper = 2.0
    }

    /// Styles for the page-turn transition.
    public enum TransitionStyle : Int {
        
        /// Scrolling transition style.
        case scroll = 0
    }

    /// Directions for page-turn transitions.
    ///
    /// For horizontal navigation, pages turn from the right side of the screen to the left as you navigate forward.
    /// For vertical navigation, pages turn from the bottom of the screen to the top as you navigate forward.
    public enum NavigationDirection : Int {

        case forward = 0

        case reverse = 1
    }
    
    /// An alias for the cache policy.
    public enum CachePolicy {
        
        case useProtocolCachePolicy
        
        case ignoringCacheData
    }
    
    
    
    // MARK: - Init
    
    private let contentViewController: IMPageContentViewController
    
    public init(_ direction: NavigationOrientation = .horizontal, cachePolicy: CachePolicy = .ignoringCacheData) {
        self.contentViewController = IMPageScrollController(direction)
        super.init(nibName: nil, bundle: nil)
    }
     
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.contentViewController = IMPageScrollController(.horizontal)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        self.contentViewController = IMPageScrollController(.horizontal)
        super.init(coder: coder)
    }
 

    
    // MARK: - UIViewController
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSubviews()
        contentViewController.delegate = self
    }
    
    private func loadSubviews() {
        addChild(contentViewController)
        contentViewController.view.frame = CGRect(origin: .zero, size: view.bounds.size)
        contentViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
        
        if view.backgroundColor == nil {
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = .white
            }
        }
    }

    
    // MARK: - Property
    
    /// The delegate object.
    ///
    /// Methods of the delegate are called in response to gesture-based navigation and orientation changes.
    open weak var delegate: IMPageViewControllerDelegate?

    /// The object that provides view controllers.
    ///
    /// Methods of the data source are called in response to gesture-based navigation.
    /// If the value of this property is nil, then gesture-based navigation is disabled.
    open weak var dataSource: IMPageViewControllerDataSource?

    /// A Boolean value that controls whether the scroll view bounces past the edge of content and back again.
    ///
    /// If the value of this property is `true`, the scroll view bounces when it encounters a boundary of the content.
    /// Bouncing visually indicates that scrolling has reached an edge of the content.
    /// If the value is `false`, scrolling stops immediately at the content boundary without bouncing.
    /// The default value is `true`.
    open var bounces: Bool = true {
        didSet {
            if let contentViewController = contentViewController as? IMPageScrollController {
                contentViewController.bounces = bounces
            }
        }
    }
    
    /// The direction along which navigation occurs.
    open var navigationOrientation: NavigationOrientation {
        get {
            contentViewController.navigationOrientation
        }
        set {
            contentViewController.navigationOrientation = newValue
        }
    }

    /// The view controller displayed by the page view controller.
    open var currentController: UIViewController? {
        contentViewController.pageControllers?.first?.viewController
    }

    /// Sets the view controller to be displayed.
    ///
    /// - Parameter controller:
    ///     The view controller  to be displayed.
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
    open func setController(
        _ controller: UIViewController?,
        direction: NavigationDirection = .forward,
        animated: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        contentViewController.setController(
            controller,
            direction: direction,
            animated: animated,
            completion: completion
        )
        
        // Cache the page controller so it can be reused.
        if cachePolicy != .ignoringCacheData,
           let pageController = contentViewController.pageControllers?.first(where: { $0.viewController === controller }) {
            if let cachedPageController = pageControllerCache.object(forKey: pageController.identifier as NSString) {
                if cachedPageController !== pageController {
                    pageControllerCache.removeAllObjects()
                    pageControllerCache.setObject(pageController, forKey: pageController.identifier as NSString)
                }
            } else {
                pageControllerCache.setObject(pageController, forKey: pageController.identifier as NSString)
            }
             
        }
    }
    
    
    
    // MARK: - Cache

    private let pageControllerCache = NSCache<NSString, IMPageController>()

    open var cachePolicy: CachePolicy = .ignoringCacheData

    open func clearCache() {
        pageControllerCache.removeAllObjects()
    }
     
    
    
    // MARK: - IMPageContentViewControllerDelegate
    
    final func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        pageControllerForItemAt pageIndex: Int,
        current: IMPageController
    ) -> IMPageController? {
        if let cachedPageController = pageControllerCache.object(forKey: IMPageController.asIdentifier(pageIndex) as NSString) {
            // Return the cached page controller.
            dataSource?.pageViewController(self, didConfigure: cachedPageController.viewController)
            return cachedPageController
        }

        guard let delegate = dataSource,
            let controller = { () -> UIViewController? in
                if pageIndex > current.number {
                   return delegate.pageViewController(self, viewControllerAfter: current.viewController)
                }
                if pageIndex < current.number {
                   return delegate.pageViewController(self, viewControllerBefore: current.viewController)
                }
                return nil
            }() else {
            return nil
        }

        let pageController = IMPageController(
            controller,
            number: pageIndex
        )

        // Cache the page controller so it can be reused.
        if cachePolicy != .ignoringCacheData {
            pageControllerCache.setObject(pageController, forKey: pageController.identifier as NSString)
        }

        return pageController
    }
    
    final func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        didScrollWith progress: CGFloat,
        for nextPageController: IMPageController?,
        current: IMPageController
    ) {
        delegate?.pageViewController(
            self,
            didScrollWith: progress,
            for: nextPageController?.viewController,
            current: current.viewController
        )
    }
    
    final func pageContentViewController(
        _ pageContentViewController: IMPageContentViewController,
        didFinishWith pageController: IMPageController
    ) {
        delegate?.pageViewController(self, didFinishWith: pageController.viewController)
    }
    
    final func pageContentViewControllerWillDrag(_ pageContentViewController: IMPageContentViewController) {
        delegate?.pageViewControllerWillDrag(self)
    }

    final func pageContentViewControllerDidEndDrag(_ pageContentViewController: IMPageContentViewController) {
        delegate?.pageViewControllerDidEndDrag(self)
    }
}
