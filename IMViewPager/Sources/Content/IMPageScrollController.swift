//
//  IMPageScrollController.swift
//  IMViewPager
//
//  Created by immortal on 2022/1/17
//

import UIKit

class IMPageScrollController: UIViewController, UIScrollViewDelegate, IMPageContentViewController {
    
    init(_ direction: NavigationOrientation) {
        self.navigationOrientation = direction
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.navigationOrientation = .horizontal
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        self.navigationOrientation = .horizontal
        super.init(coder: coder)
    }
    
    var bounces: Bool = true

    
    
    // MARK: - UIViewController
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubviews()
        updateBounce()
        scrollView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func loadSubviews() {
        scrollView.frame = CGRect(origin: .zero, size: view.bounds.size)
        view.addSubview(scrollView)
        updateContent(for: scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent(for: scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContent(for: scrollView)
        scrollToCurrent()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.scrollToCurrent()
        }, completion: nil)
    }
    
    
    
    // MARK: - IMPageContentViewController
    
    private(set) var isAnimating: Bool = false
    
    weak var delegate: IMPageContentViewControllerDelegate?

    var navigationOrientation: NavigationOrientation = .horizontal {
        didSet {
            updateBounce()
        }
    }
    
    var pageControllers: [IMPageController]? {
        var pageControllers = visiblePageControllers.map({ $0.value })
        if let currentController = current {
            pageControllers.insert(currentController, at: 0)
        }
        return pageControllers
    }

    func setController(
        _ controller: UIViewController?,
        direction: NavigationDirection,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        if isAnimating {
            // Fixed the scolling animation.
            return
        }
        isAnimating = animated
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

            let pageController = IMPageController(
                controller,
                number: pageIndex
            )

            if let current = current {
                if current.viewController == pageController.viewController {
                    return
                }
                switch direction {
                    case .forward:
                        layoutPageController(pageController, in: .max)
                        let contentOffset: CGPoint = {
                            switch navigationOrientation {
                                case .horizontal:
                                    return CGPoint(x: scrollOffset + scrollWidth, y: 0)
                                case .vertical:
                                    return CGPoint(x: 0, y: scrollOffset + scrollWidth)
                            }
                        }()
                        preventsFuncForScrollViewDidScroll = animated
                        scrollView.setContentOffset(contentOffset, animated: animated)
                     case .reverse:
                        layoutPageController(pageController, in: .min)
                        let contentOffset: CGPoint = {
                            switch navigationOrientation {
                                case .horizontal:
                                    return CGPoint(x: scrollOffset - scrollWidth, y: 0)
                                case .vertical:
                                    return CGPoint(x: 0, y: scrollOffset - scrollWidth)
                            }
                        }()
                        preventsFuncForScrollViewDidScroll = animated
                        scrollView.setContentOffset(contentOffset, animated: animated)
                }
                
            } else {
                layoutPageController(pageController, in: .mid)
                current = pageController
                updateContent(for: scrollView)

                if animated {
                    offsetIndex = {
                        switch direction {
                            case .forward: return -1
                            case .reverse: return  1
                        }
                    }()
                    let origin: CGPoint = {
                        switch navigationOrientation {
                            case .horizontal:
                                return CGPoint(x: scrollWidth * CGFloat(pageController.number - offsetIndex), y: 0)
                            case .vertical:
                                return CGPoint(x: 0, y: scrollWidth * CGFloat(pageController.number - offsetIndex))
                        }
                    }()
                    preventsFuncForScrollViewDidScroll = true
                    pageController.containerView.frame.origin = origin

                    if isViewLoaded && view.window != nil {
                        scrollToCurrent()
                    }
                } else {
                    offsetIndex = 0
                }
             }
        } else {
            
            guard let current = current else {
                return
            }
            visiblePageControllers[current.number] = current
            self.current = nil
            if animated {
                let contentOffset: CGPoint = {
                    switch direction {
                        case .forward:
                            switch navigationOrientation {
                                case .horizontal:
                                    return CGPoint(x: current.containerView.frame.maxX, y: 0)
                                case .vertical:
                                    return CGPoint(x: 0, y: current.containerView.frame.maxY)
                            }
                        case .reverse:
                            switch navigationOrientation {
                                case .horizontal:
                                return CGPoint(x: current.containerView.frame.minX - scrollWidth, y: 0)
                                case .vertical:
                                    return CGPoint(x: 0, y: current.containerView.frame.minY - scrollWidth)
                            }
                    }
                }()
                preventsFuncForScrollViewDidScroll = true
                scrollView.setContentOffset(contentOffset, animated: true)
            } else {
                offsetIndex = 0
                scrollToCurrent()
                removeInvalidVisiblePageControllers()
            }
        }
    }


    
    // MARK: - Convenience

    /// The page controller displayed by the page view controller.
    private var current: IMPageController? {
        didSet {
            // When the current is nil, scrolling is disabled.
            scrollView.isScrollEnabled = current != nil
        }
    }

    private var preventsFuncForScrollViewDidScroll: Bool = false
    
    private var pageSize: CGSize {
        view.bounds.size
    }

    private var scrollWidth: CGFloat {
        navigationOrientation == .horizontal ? view.bounds.width : view.bounds.height
    }

    private var scrollOffset: CGFloat {
        navigationOrientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    
    private func scrollToCurrent() {
        preventsFuncForScrollViewDidScroll = true
        if let current = current {
            scrollView.setContentOffset(current.containerView.frame.origin, animated: true)
        } else {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
    
    /// Ensure the continuous sliding.
    private func updateContent(for scrollView: UIScrollView) {
        let contentSize = view.bounds.size
        if scrollView.contentSize != contentSize {
            preventsFuncForScrollViewDidScroll = true
            scrollView.contentSize = contentSize
            preventsFuncForScrollViewDidScroll = false
        }
 
        let contentInset: UIEdgeInsets = {
            guard let current = current else {
                return .zero
            }
            let index = current.number - offsetIndex
            if index > 0 {
                switch navigationOrientation {
                    case .horizontal:
                        return UIEdgeInsets(
                            top: 0,
                            left: pageSize.width,
                            bottom: 0,
                            right: pageSize.width * CGFloat(10 + index)
                        )
                    case .vertical:
                        return UIEdgeInsets(
                            top: pageSize.height,
                            left: 0,
                            bottom: pageSize.height * CGFloat(10 + index),
                            right: 0
                        )
                }
            } else if index < 0 {
                switch navigationOrientation {
                    case .horizontal:
                        return UIEdgeInsets(
                            top: 0,
                            left: pageSize.width * CGFloat(10 - index),
                            bottom: 0,
                            right: pageSize.width
                        )
                    case .vertical:
                        return UIEdgeInsets(
                            top: pageSize.height * CGFloat(10 - index),
                            left: 0,
                            bottom: pageSize.height,
                            right: 0
                        )
                }
            }
            switch navigationOrientation {
                case .horizontal:
                    return UIEdgeInsets(
                        top: 0,
                        left: pageSize.width,
                        bottom: 0,
                        right: pageSize.width
                    )
                case .vertical:
                    return UIEdgeInsets(
                        top: pageSize.height,
                        left: 0,
                        bottom: pageSize.height,
                        right: 0
                    )
            }
        }()
        if scrollView.contentInset != contentInset {
            preventsFuncForScrollViewDidScroll = true
            scrollView.contentInset = contentInset
            preventsFuncForScrollViewDidScroll = false
        }
    }
    
    private func updateBounce() {
        scrollView.alwaysBounceHorizontal = navigationOrientation == .horizontal
        scrollView.alwaysBounceVertical = navigationOrientation == .vertical
    }
    
    
    
    // MARK: - Page
    
    private var offsetIndex: Int = 0
    
    private var visiblePageControllers: [Int : IMPageController] = [:]

    /// Remove the invalid visible page controllers that is not current page.
    private func removeInvalidVisiblePageControllers() {
        visiblePageControllers.forEach {
            if $0.value !== current {
                $0.value.removeFromParent()
            }
        }
        visiblePageControllers.removeAll()
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
        if let visiblePageController = visiblePageControllers[pageIndex] {
            // Return the visible page controller.
            return visiblePageController
        }
        
        return delegate?.pageContentViewController(self, pageControllerForItemAt: pageIndex, current: current)
    }
    
    /// Loads the page controller.
    private func goPage(current: IMPageController, forPage pageIndex: Int, location: SpineLocation) {
        guard let nextPageController = pageController(current: current, forPage: pageIndex) else {
            // Ensure that index calculations are correct.
            let contentInset: UIEdgeInsets = {
                var contentInset = scrollView.contentInset
                switch location {
                    case .min, .lower:
                        contentInset.left = -current.containerView.frame.minX
                        contentInset.top = -current.containerView.frame.minY
                    case .max, .upper:
                        contentInset.right = current.containerView.frame.minX
                        contentInset.bottom = current.containerView.frame.minY
                    default:
                        break
                }
                return contentInset
            }()
            if scrollView.contentInset != contentInset {
                preventsFuncForScrollViewDidScroll = true
                scrollView.contentInset = contentInset
                preventsFuncForScrollViewDidScroll = false
            }
            
            // Cancel bounces.
            if !bounces ||
                (scrollView.alwaysBounceHorizontal && scrollView.contentOffset.y != .zero) ||
                (scrollView.alwaysBounceVertical && scrollView.contentOffset.x != .zero) {
                let contentOffset = current.containerView.frame.origin
                if scrollView.contentOffset != contentOffset {
                    preventsFuncForScrollViewDidScroll = true
                    scrollView.contentOffset = contentOffset
                    preventsFuncForScrollViewDidScroll = false
                }
            }
            return
        }
         
        // Notify a progress callback.
        callBackProgress(current: current, next: nextPageController)

        layoutPageController(nextPageController, in: location)
    }
    
    private func layoutPageController(_ pageController: IMPageController, in location: SpineLocation) {
        guard !pageController.isVisible else {
            return
        }
        let origin: CGPoint = {
            switch navigationOrientation {
                case .horizontal:
                   return CGPoint(
                        x: scrollWidth * CGFloat(pageController.number - offsetIndex),
                        y: 0
                    )

                case .vertical:
                    return CGPoint(
                        x: 0,
                        y: scrollWidth * CGFloat(pageController.number - offsetIndex)
                    )
            }
        }()
        pageController.addToParent(self, in: scrollView)
        
        if location == .mid {
            return
        }
        pageController.containerView.frame.origin = origin
        visiblePageControllers[pageController.number] = pageController
        updateContent(for: scrollView)
    }

    /// Replace the current page controller immediately, if the updates are pending.
    private func replaceCurrentIfNeeded(for current: IMPageController, with preferredSpineLocation: SpineLocation) -> IMPageController {
        switch preferredSpineLocation {
            case .upper:
                let pageIndex = current.number + 1
                if let visiblePageController = visiblePageControllers[pageIndex] {
                    self.current = visiblePageController
                    callBackProgress(current: current, next: visiblePageController)
                    visiblePageControllers.removeValue(forKey: pageIndex)
                    current.removeFromParent()
                    delegate?.pageContentViewController(self, didFinishWith: visiblePageController)
                    return visiblePageController
                }
            
            case .lower:
                let pageIndex = current.number - 1
                if let visiblePageController = visiblePageControllers[pageIndex] {
                    callBackProgress(current: current, next: visiblePageController)
                    self.current = visiblePageController
                    visiblePageControllers.removeValue(forKey: pageIndex)
                    current.removeFromParent()
                    delegate?.pageContentViewController(self, didFinishWith: visiblePageController)
                    return visiblePageController
                }

            default:
                break
        }
        return current
    }
    
    // Notify a progress callback.
    private func callBackProgress(current: IMPageController, next: IMPageController) {
        let progress: CGFloat = {
            if !next.isVisible {
                return 0
            }
            switch navigationOrientation {
                case .horizontal:
                    return (scrollOffset - current.containerView.frame.minX) / scrollWidth
                case .vertical:
                    return (scrollOffset - current.containerView.frame.minY) / scrollWidth
            }
        }()
        delegate?.pageContentViewController(self, didScrollWith: min(abs(progress), 1.0), for: next, current: current)
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
            if let visiblePageController = visiblePageControllers[finishedIndex],
               visiblePageController !== current {
                self.current = visiblePageController
                visiblePageControllers.removeValue(forKey: finishedIndex)
                current.removeFromParent()

                // Fix the current page's position.
                visiblePageController.containerView.frame.origin = .zero
                offsetIndex = finishedIndex
                preventsFuncForScrollViewDidScroll = true
                scrollView.contentInset = .zero
                scrollView.contentOffset = .zero
                preventsFuncForScrollViewDidScroll = false
                
                delegate?.pageContentViewController(self, didFinishWith: visiblePageController)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize != .zero,
            !preventsFuncForScrollViewDidScroll else {
            return
        }

        if let current = current {
            let preferredIndex = preferredIndex(for: current)
            let preferredSpineLocation = preferredSpineLocation(for: current, preferredIndex: preferredIndex)
            goPage(
                current: replaceCurrentIfNeeded(for: current, with: preferredSpineLocation),
                forPage: preferredIndex,
                location: preferredSpineLocation
            )
        }
         
        // The scroll view did finish scoll.
        if !scrollView.isTracking && !scrollView.isDecelerating {
           scrollViewDidFinishScroll(scrollView)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        preventsFuncForScrollViewDidScroll = false
        isAnimating = false
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !scrollView.isTracking else { return }
        scrollViewDidScroll(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Fixed the wrong bounces.
        updateContent(for: scrollView)
        preventsFuncForScrollViewDidScroll = false
        delegate?.pageContentViewControllerWillDrag(self)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.pageContentViewControllerDidEndDrag(self)
    }
}
