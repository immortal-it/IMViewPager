//
//  IMPageViewController.swift
//  IMViewPager
//
//  Created by immortal on 2021/8/9
//

import UIKit

// MARK: IMPageViewControllerDataSource

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
}
 


// MARK: IMPageViewControllerDelegate

///
/// The delegate of a page view controller must adopt the PageViewControllerDelegate protocol.
/// These methods allow the delegate to receive a notification when the device orientation changes and when the user navigates to a new page.
public protocol IMPageViewControllerDelegate: AnyObject {

    func pageViewController(
        _ pageViewController: IMPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    )
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollAfter viewController: UIViewController,
        pendingViewController: UIViewController,
        progress: CGFloat
    )
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollBefore viewController: UIViewController,
        pendingViewController: UIViewController,
        progress: CGFloat
    )
    
    func pageViewControllerWillDrag(_ pageViewController: IMPageViewController)

    func pageViewControllerDidEndDrag(_ currentController: IMPageViewController)
}


public extension IMPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: IMPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {}
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollAfter viewController: UIViewController,
        pendingViewController: UIViewController,
        progress: CGFloat
    ) {}
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollBefore viewController: UIViewController,
        pendingViewController: UIViewController,
        progress: CGFloat
    ) {}
    
    func pageViewControllerWillDrag(_ pageViewController: IMPageViewController) {}

    func pageViewControllerDidEndDrag(_ currentController: IMPageViewController) {}
}



/// A container view controller that manages navigation between pages of content, where a child view controller manages each page.
///
/// Page view controller–navigation can be controlled programmatically by your app or directly by the user using gestures.
/// When navigating from page to page, the page view controller uses the transition that you specify to animate the change.
@available(iOS 9.0, *)
open class IMPageViewController: UIViewController, UIScrollViewDelegate {

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
        case none = -1000.0

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

        /// Page curl transition style.
        case pageCurl = 0

        /// Scrolling transition style.
        case scroll = 1
    }

    public enum NavigationDirection : Int {

        case forward = 0

        case reverse = 1
    }

    /// The delegate object.
    ///
    /// Methods of the delegate are called in response to gesture-based navigation and orientation changes.
    open weak var delegate: IMPageViewControllerDelegate?

    /// The object that provides view controllers.
    ///
    /// Methods of the data source are called in response to gesture-based navigation.
    /// If the value of this property is nil, then gesture-based navigation is disabled.
    open weak var dataSource: IMPageViewControllerDataSource?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    public init(_ direction: NavigationOrientation = .horizontal) {
        self.navigationOrientation = direction
        super.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.navigationOrientation = .horizontal
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        self.navigationOrientation = .horizontal
        super.init(coder: coder)
    }

    
    
    // MARK: - UIViewController

    open override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadSubviews()
        updateBounce()
    }

    private func loadSubviews() {
        if view.backgroundColor == nil {
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = .white
            }
        }
        scrollView.frame = CGRect(origin: .zero, size: view.bounds.size)
        view.addSubview(scrollView)
        updateContent(for: scrollView, pageSize: pageSize)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if scrollView.contentSize != pageSize {
            updateContent(for: scrollView, pageSize: pageSize)
        }
        
        scrollToCurrent()
    }


    
    // MARK: - Property

    /// A Boolean value that controls whether the scroll view bounces past the edge of content and back again.
    ///
    /// If the value of this property is `true`, the scroll view bounces when it encounters a boundary of the content.
    /// Bouncing visually indicates that scrolling has reached an edge of the content.
    /// If the value is `false`, scrolling stops immediately at the content boundary without bouncing.
    /// The default value is `true`.
    public var bounces: Bool = true
    
    /// The direction along which navigation occurs.
    open var navigationOrientation: NavigationOrientation = .horizontal {
        didSet {
            updateBounce()
        }
    }

    private var current: IMPageController? {
        didSet {
            scrollView.isScrollEnabled = current != nil
        }
    }

    /// The view controller displayed by the page view controller.
    open var currentController: UIViewController? {
        current?.viewController
    }

    private var preventsFuncForScrollViewDidScroll: Bool = false

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
        if let controller = controller {
            
            let pageIndex: Int = {
                switch direction {
                    case .forward:
                        if let current = current {
                            return current.number + 1
                        }
                    case .reverse:
                        if let current = current {
                            return current.number - 1
                        }
                }
                return 0
            }()
            
            if let pageController = pageController(for: controller, with: pageIndex) {
                if current == nil {
                    layoutPageController(pageController, in: .mid)
                    current = pageController
                    if animated {
                        let contentOffset: CGPoint = {
                            switch direction {
                                case .forward:
                                    switch navigationOrientation {
                                        case .horizontal:
                                            return CGPoint(x: scrollOffset - scrollWidth, y: 0)
                                        case .vertical:
                                            return CGPoint(x: 0, y: scrollOffset - scrollWidth)
                                    }

                                case .reverse:
                                    switch navigationOrientation {
                                        case .horizontal:
                                            return CGPoint(x: scrollOffset + scrollWidth, y: 0)
                                        case .vertical:
                                            return CGPoint(x: 0, y: scrollOffset + scrollWidth)
                                    }
                            }
                        }()
                        
                        preventsFuncForScrollViewDidScroll = true
                        scrollView.setContentOffset(contentOffset, animated: false)
 
                        if view.superview != nil {
                            scrollToCurrent()
                        }
                    }
                    
                } else {
                    preventsFuncForScrollViewDidScroll = animated
                    switch direction {
                        case .forward:
                            layoutPageController(pageController, in: .upper)
                            switch navigationOrientation {
                                case .horizontal:
                                    scrollView.setContentOffset(CGPoint(x: scrollOffset + scrollWidth, y: 0), animated: animated)
                                case .vertical:
                                    scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset + scrollWidth), animated: animated)
                            }
                        case .reverse:
                            layoutPageController(pageController, in: .lower)
                            switch navigationOrientation {
                                case .horizontal:
                                    scrollView.setContentOffset(CGPoint(x: scrollOffset - scrollWidth, y: 0), animated: animated)
                                case .vertical:
                                    scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset - scrollWidth), animated: animated)
                            }
                    }
                }
            }
        } else {
            reset()
        }
    }

    private func reset() {
        offsetIndex = 0
        scrollingIndex = 0
        scrollView.contentInset = .zero
        scrollView.contentOffset = .zero
        if let current = current {
            current.removeFromParent()
            self.current = nil
        }
        removeInvalidVisiblePageControllers()
        clearCache()
    }

    private var pageSize: CGSize {
        view.bounds.size
    }

    private var scrollWidth: CGFloat {
        navigationOrientation == .horizontal ? view.bounds.width : view.bounds.height
    }

    private var scrollOffset: CGFloat {
        navigationOrientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }

    private var scrollingIndex: Int = 0

    private var offsetIndex: Int = 0
    
    private func updateBounce() {
        switch navigationOrientation {
            case .horizontal:
                scrollView.alwaysBounceHorizontal = true
                scrollView.alwaysBounceVertical = false
            case .vertical:
                scrollView.alwaysBounceHorizontal = false
                scrollView.alwaysBounceVertical = true
        }
    }



    // MARK: - Cache

    open var supportCache: Bool = true

    private let pageControllerCache = NSCache<NSString, IMPageController>()

    open func clearCache() {
        pageControllerCache.removeAllObjects()
    }

    private var visiblePageControllers: [Int : IMPageController] = [:]

    /// Remove the invalid visible page controllers that is not current page.
    private func removeInvalidVisiblePageControllers() {
        visiblePageControllers.forEach {
            $0.value.removeFromParent()
        }
        visiblePageControllers.removeAll()
    }



    // MARK: - Convenience

    /// Ensure the continuous sliding.
    private func updateContent(for scrollView: UIScrollView, pageSize: CGSize) {
        if scrollView.contentSize != pageSize {
            scrollView.contentSize = pageSize
        }
        let index = scrollingIndex - offsetIndex
        if index > 0 {
            switch navigationOrientation {
                case .horizontal:
                    scrollView.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: pageSize.width * CGFloat(1 + index)
                    )
                case .vertical:
                    scrollView.contentInset = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: pageSize.height * CGFloat(1 + index),
                        right: 0
                    )
            }
        } else if index < 0 {
            switch navigationOrientation {
                case .horizontal:
                    scrollView.contentInset = UIEdgeInsets(
                        top: 0,
                        left: pageSize.width * CGFloat(1 - index),
                        bottom: 0,
                        right: 0
                    )
                case .vertical:
                    scrollView.contentInset = UIEdgeInsets(
                        top: pageSize.height * CGFloat(1 - index),
                        left: 0,
                        bottom: 0,
                        right: 0
                    )
            }
        } else if index < 0 {
            scrollView.contentInset = .zero
        }
    }
    
    private func scrollToCurrent() {
        if let current = current {
            scrollView.setContentOffset(current.containerView.frame.origin, animated: true)
        } else {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }

    private func preferredIndex(for current: IMPageController) -> Int {
        let offset = scrollOffset
        switch navigationOrientation {
        case .horizontal:
            if current.containerView.frame.minX < offset {
                return Int(ceil(offset / scrollWidth)) + offsetIndex
            } else {
                return Int(floor(offset / scrollWidth)) + offsetIndex
            }
        case .vertical:
            if current.containerView.frame.minY < offset {
                return Int(ceil(offset / scrollWidth)) + offsetIndex
            } else {
                return Int(floor(offset / scrollWidth)) + offsetIndex
            }
        }
    }

    private func preferredSpineLocation(for current: IMPageController, preferredIndex: Int) -> SpineLocation {
        let offsetIndex = preferredIndex - current.number
        if offsetIndex > 1 {
            return .upper
        }
        if offsetIndex == 1 {
            return .max
        }
        if offsetIndex < -1 {
            return .lower
        }
        if offsetIndex == -1 {
            return .min
        }
        return .mid
    }

    private func pageController(current: IMPageController, forPage pageIndex: Int) -> IMPageController? {
        if let cachedPageController = pageControllerCache.object(forKey: IMPageController.asIdentifier(pageIndex) as NSString) {
            // Return the cached page controller.
            return cachedPageController
        }

        if let visiblePageController = visiblePageControllers[pageIndex] {
            // Return the visible page controller.
            return visiblePageController
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
        if supportCache {
            pageControllerCache.setObject(pageController, forKey: pageController.identifier as NSString)
        }

        return pageController
    }
    
    private func pageController(for viewController: UIViewController, with pageIndex: Int) -> IMPageController? {
        if currentController == viewController {
            return nil
        }
        
        let pageController = IMPageController(
            viewController,
            number: pageIndex
        )
        
        // Cache the page controller so it can be reused.
        if supportCache {
            pageControllerCache.setObject(pageController, forKey: pageController.identifier as NSString)
        }
                
        return pageController
    }

    /// Replace the current page controller immediately, if the updates are pending.
    private func updateIfNeeded(for current: IMPageController, with preferredSpineLocation: SpineLocation) {
        switch preferredSpineLocation {
            case .upper:
                let pageIndex = current.number + 1
                if let pageController = visiblePageControllers[pageIndex] {
                    callBackProgress(pageController, location: preferredSpineLocation)

                    current.removeFromParent()
                    visiblePageControllers.removeValue(forKey: pageIndex)
                    self.current = pageController
                 }

            case .lower:
                let pageIndex = current.number - 1
                if let pageController = visiblePageControllers[pageIndex] {
                    callBackProgress(pageController, location: preferredSpineLocation)

                    current.removeFromParent()
                    visiblePageControllers.removeValue(forKey: pageIndex)
                    self.current = pageController
                }

            case .mid:
                removeInvalidVisiblePageControllers()

            default:
                break
        }
    }

    /// Loads the page controller.
    private func goPage(_ pageIndex: Int, location: SpineLocation) {
        guard let current = current else {
            return
        }

        guard let pageController = pageController(current: current, forPage: pageIndex) else {
            // Ensure that index calculations are correct.
            switch location {
                case .min, .lower:
                    scrollView.contentInset.left = -current.containerView.frame.minX
                    scrollView.contentInset.top = -current.containerView.frame.minY
                case .max, .upper:
                    scrollView.contentInset.right = current.containerView.frame.minX
                    scrollView.contentInset.bottom = current.containerView.frame.minY
                default:
                    break
            }
            return
        }
         
        // Notify a progress callback.
        callBackProgress(pageController, location: location)
        
        layoutPageController(pageController, in: location)
    }
    
    // Notify a progress callback.
    private func callBackProgress(_ pageController: IMPageController, location: SpineLocation) {
        guard let current = current else { return }
        let progress: CGFloat = {
            switch navigationOrientation {
                case .horizontal:
                    return (scrollOffset - current.containerView.frame.minX) / scrollWidth

                case .vertical:
                    return (scrollOffset - current.containerView.frame.minY) / scrollWidth
            }
        }()
        if pageController !== current {
            switch location {
                case .min, .lower:
                    delegate?.pageViewController(
                        self,
                        didScrollBefore: current.viewController,
                        pendingViewController: pageController.viewController,
                        progress: min(abs(progress), 1.0)
                    )
                
                case .max, .upper:
                    delegate?.pageViewController(
                        self,
                        didScrollAfter: current.viewController,
                        pendingViewController: pageController.viewController,
                        progress: min(abs(progress), 1.0)
                    )
                default:
                    break
            }
        }
    }
    
    private func layoutPageController(_ pageController: IMPageController, in location: SpineLocation) {
        guard !pageController.isVisible else {
            return
        }
        let pageIndex = pageController.number
        pageController.addToParent(self, in: scrollView)
        switch location {
            case .min, .lower, .max, .upper:
                switch navigationOrientation {
                    case .horizontal:
                        pageController.containerView.frame.origin = CGPoint(
                            x: scrollWidth * CGFloat(pageIndex - offsetIndex),
                            y: 0
                        )

                    case .vertical:
                        pageController.containerView.frame.origin = CGPoint(
                            x: 0,
                            y: scrollWidth * CGFloat(pageIndex - offsetIndex)
                        )
                }
            
                // Notify a progress callback.
                callBackProgress(pageController, location: location)

            default:
                return
        }
    
        visiblePageControllers[pageIndex] = pageController
        scrollingIndex = pageIndex
        updateContent(for: scrollView, pageSize: pageSize)
    }



    // MARK: UIScrollViewDelegate

    /// The scroll view did finish scoll.
    private func scrollViewDidFinishScroll(_ scrollView: UIScrollView) {

        // Remove the visible page controllers that is not current page.
        defer {
            removeInvalidVisiblePageControllers()
        }

        // Replace the current page.
        if let current = current {
            let finishedIndex = preferredIndex(for: current)
            if let pageController = visiblePageControllers[finishedIndex],
                pageController !== current {
                visiblePageControllers.removeValue(forKey: finishedIndex)
                current.removeFromParent()

                pageController.containerView.frame.origin = .zero
                self.current = pageController

                preventsFuncForScrollViewDidScroll = true
                // Fix the current page's position.
                offsetIndex = finishedIndex
                scrollView.contentInset = .zero
                scrollView.contentOffset = .zero
                preventsFuncForScrollViewDidScroll = false

                delegate?.pageViewController(
                    self,
                    didFinishAnimating: true,
                    previousViewControllers: [pageController.viewController],
                    transitionCompleted: true
                )
            } else {
                delegate?.pageViewController(
                    self,
                    didFinishAnimating: true,
                    previousViewControllers: [current.viewController],
                    transitionCompleted: true
                )
            }
        }
    }

    
    
    // MARK: UIScrollViewDelegate

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize != .zero,
            !preventsFuncForScrollViewDidScroll else {
            return
        }

        if let current = current {
            let preferredIndex = preferredIndex(for: current)
            let preferredSpineLocation = preferredSpineLocation(for: current, preferredIndex: preferredIndex)

            // Replace the current page controller immediately, if the updates are pending.
            updateIfNeeded(for: current, with: preferredSpineLocation)

            goPage(preferredIndex, location: preferredSpineLocation)
        }
         
        // The scroll view did finish scoll.
        if !scrollView.isTracking && !scrollView.isDecelerating {
           scrollViewDidFinishScroll(scrollView)
        }
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        preventsFuncForScrollViewDidScroll = false
        scrollViewDidEndDecelerating(scrollView)
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !scrollView.isTracking else { return }
        scrollViewDidScroll(scrollView)
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.pageViewControllerWillDrag(self)
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.pageViewControllerDidEndDrag(self)
    }
}
