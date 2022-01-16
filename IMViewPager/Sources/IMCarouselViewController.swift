//
//  IMCarouselViewController.swift
//  IMViewPager
//
//  Created by immortal on 2022/1/11
//  Copyright (c) 2022 manjitech. All rights reserved.
//

import UIKit

public protocol IMCarouselViewControllerDataSource: AnyObject {

    func numberOfItems(in carouselViewController: IMCarouselViewController) -> Int

    func carouselViewController(_ carouselViewController: IMCarouselViewController, viewControllerForItemAt index: Int) -> UIViewController
}

open class IMCarouselViewController: UIViewController, IMPageViewControllerDataSource, IMPageViewControllerDelegate {

    public typealias NavigationDirection = IMPageViewController.NavigationDirection

    private let indexViewControllerCache = NSCache<NSString, UIViewController>()

    private let pageViewController = IMPageViewController()

    open var direction: NavigationDirection = .forward

    public weak var dataSource: IMCarouselViewControllerDataSource?

    deinit {
        stop()
    }

    

    // MARK: UIViewController

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(pageViewController)
        pageViewController.view.frame = view.bounds
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.supportCache = false
        pageViewController.delegate = self
        pageViewController.dataSource = self

        if dataSource != nil,
            pageViewController.currentController == nil {
            reloadData()
        }
    }

    open func reloadData() {
        func fetchCurrentPage() {
            pageViewController.setController(
                indexViewController(forPage: 0),
                direction: direction,
                animated: true,
                completion: nil
            )
        }
        
        stop()
        indexViewControllerCache.removeAllObjects()
        
        if numberOfItems > 1 {
            if pageViewController.currentController == nil {
                fetchCurrentPage()
            }
            start()
        } else if numberOfItems == 1 {
            fetchCurrentPage()
        }
    }



    // MARK: Convenience
    
    public final var numberOfItems: Int {
        dataSource?.numberOfItems(in: self) ?? 0
    }

    private func index(forViewController viewController: UIViewController) -> Int {
        viewController.indexOfCarousel
    }

    private func indexViewController(forPage pageIndex: Int) -> UIViewController {
        guard let dataSource = dataSource else {
            fatalError("Unexpected dataSource in carousel view controller.")
        }
        let identifier = String(describing: pageIndex) as NSString

        if let cachedController = indexViewControllerCache.object(forKey: identifier) {
            // Return the cached view controller.
            return cachedController
        }
        else {
            // Instantiate and configure a `UIViewController` for the `index`.
            let controller = dataSource.carouselViewController(self, viewControllerForItemAt: pageIndex)
            controller.indexOfCarousel = pageIndex
            
            // Cache the view controller so it can be reused.
            indexViewControllerCache.setObject(controller, forKey: identifier)

            // Return the newly created and cached view controller.
            return controller
        }
    }



    // MARK: - PageViewControllerDataSource

    open func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = index(forViewController: viewController)
        if index > 0 {
            return indexViewController(forPage: index - 1)
        } else {
            return indexViewController(forPage: numberOfItems - 1)
        }
    }

    open func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = index(forViewController: viewController)
        if index < numberOfItems - 1 {
            return indexViewController(forPage: index + 1)
        } else {
            return indexViewController(forPage: 0)
        }
    }



    // MARK: - PageViewControllerDelegate


    open func pageViewControllerWillDrag(_ pageViewController: IMPageViewController) {
        pause()
    }

    open func pageViewControllerDidEndDrag(_ currentController: IMPageViewController) {
        delay()
    }



    // MARK: - Timer

    /// 定时时长，默认`3.0s`
    open var duration: TimeInterval = 3.0

    private var timer: Timer?

    private func start() {
        let timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] timer in
            self?.scheduledTimer(timer)
        }
        timer.fireDate = Date(timeInterval: duration, since: Date())
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func pause() {
        timer?.fireDate = .distantFuture
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func delay() {
        timer?.fireDate = Date(timeInterval: duration, since: Date())
    }

    private func scheduledTimer(_ timer: Timer) {
        guard let currentController = pageViewController.currentController else {
            fatalError("Unexpected view controller type in page view controller.")
        }
        let index = currentController.indexOfCarousel
        let nextIndex: Int = {
            switch direction {
                case .forward:
                    return index < numberOfItems - 1 ? index + 1 : 0

                case .reverse:
                    return index > 0 ? index - 1 : numberOfItems - 1
            }
        }()
        pageViewController.setController(
            indexViewController(forPage: nextIndex),
            direction: direction,
            animated: true
        )
    }
}


private extension UIViewController {
    
   /// Cache event assistant.
   var indexOfCarousel: Int {
       get {
           Runtime.getAssociatedObject(self, property: "UIViewController.indexOfCarousel") ?? 0
       }
       set {
           Runtime.setAssociatedObject(self, property: "UIViewController.indexOfCarousel", value: newValue)
       }
   }
}
