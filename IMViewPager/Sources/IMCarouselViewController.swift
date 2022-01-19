//
//  IMCarouselViewController.swift
//  IMViewPager
//
//  Created by immortal on 2022/1/11
//

import UIKit

public protocol IMCarouselViewControllerDataSource: AnyObject {

    /// Asks your data source object for the number of items in the carousel view.
    ///
    /// - Parameter carouselViewController:
    ///     The carousel view controller requesting this information.
    ///
    /// - Returns:
    ///     The number of items in carouselViewController.
    ///
    func numberOfItems(in carouselViewController: IMCarouselViewController) -> Int

    /// Returns the displayed view controller.
    ///
    /// - Parameter carouselViewController:
    ///     The carousel view controller.
    ///
    /// - Parameter index:
    ///     The carousel index.
    ///
    /// - Returns:
    ///     The displayed view controller.
    ///
    func carouselViewController(_ carouselViewController: IMCarouselViewController, viewControllerForItemAt index: Int) -> UIViewController
    
    /// Called after the cached controller's view is displayed.
    ///
    /// - Parameter carouselViewController:
    ///     The carousel view controller.
    ///
    /// - Parameter cachedViewController:
    ///     The cached view controller to be displayed.
    ///
    func carouselViewController(_ carouselViewController: IMCarouselViewController, didConfigure cachedViewController: UIViewController)
}

public extension IMCarouselViewControllerDataSource {
    
    func carouselViewController(_ carouselViewController: IMCarouselViewController, didConfigure cachedViewController: UIViewController) {
         
    }
}

public protocol IMCarouselViewControllerDelegate: AnyObject {

    
    /// Called after the replace is finished.
    ///
    /// - Parameter carouselViewController:
    ///     The carousel view controller.
    ///
    /// - Parameter viewController:
    ///     The current visible view controller.
    ///
    func carouselViewController(_ carouselViewController: IMCarouselViewController, didFinishWith viewController: UIViewController)
}


open class IMCarouselViewController: UIViewController, IMPageViewControllerDataSource, IMPageViewControllerDelegate {

    public typealias NavigationDirection = IMPageViewController.NavigationDirection

    private let indexViewControllerCache = NSCache<NSString, UIViewController>()

    private let pageViewController = IMPageViewController()
    
    private let pageControl = UIPageControl()

    open var direction: NavigationDirection = .forward

    open weak var dataSource: IMCarouselViewControllerDataSource?

    open weak var delegate: IMCarouselViewControllerDelegate?

    deinit {
        stop()
    }

    open var isPageControlHidden: Bool = true {
        didSet {
            pageControl.isHidden = isPageControlHidden
        }
    }


    // MARK: UIViewController

    open override func viewDidLoad() {
        super.viewDidLoad()
        setSubviews()
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageControl.addTarget(self, action: #selector(pageControlDidChangeValue(_:)), for: .valueChanged)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if dataSource != nil,
            pageViewController.currentController == nil {
            reloadData(false)
        }
    }
    
    private func setSubviews() {
        addChild(pageViewController)
        pageViewController.view.frame = view.bounds
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
 
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.layer.shadowOpacity = 0.5
        pageControl.layer.shadowOffset = .zero
        pageControl.layer.shadowRadius = 10.0
        view.addSubview(pageControl)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }

    open func reloadData(_ animated: Bool = true) {
        func fetchCurrentPage() {
            pageViewController.setController(
                indexViewController(forPage: 0),
                direction: direction,
                animated: animated,
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
        
        pageControl.numberOfPages = numberOfItems
        pageControl.currentPage = 0
        pageControl.isHidden = numberOfItems < 2 || isPageControlHidden
    }
    
    @objc private func pageControlDidChangeValue(_ sender: UIPageControl) {
        guard let currentController = pageViewController.currentController else { return }
        delay()
        pageViewController.setController(
            indexViewController(forPage: sender.currentPage),
            direction: currentController.indexOfCarousel < sender.currentPage ? .forward : .reverse,
            animated: true
        )
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
            dataSource.carouselViewController(self, didConfigure: cachedController)
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
        if index < 1 {
            return indexViewController(forPage: numberOfItems - 1)
        }
        return indexViewController(forPage: index - 1)
    }

    open func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = index(forViewController: viewController)
        if index < numberOfItems - 1 {
            return indexViewController(forPage: index + 1)
        }
        return indexViewController(forPage: 0)
    }
    
    open func pageViewController(_ pageViewController: IMPageViewController, didFinishWith viewController: UIViewController) {
        delegate?.carouselViewController(self, didFinishWith: viewController)
        pageControl.currentPage = viewController.indexOfCarousel
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
        guard let currentController = pageViewController.currentController,
              numberOfItems > 1 else {
            stop()
            return
        }
        guard !pageControl.isTracking else {
            return
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
