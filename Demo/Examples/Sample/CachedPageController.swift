//
//  CachedPageController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit
import IMViewPager
 
class CachedPageController: IMPageViewController, IMPageViewControllerDataSource {
     
    private let indexViewControllerCache = NSCache<NSString, IndexViewController>()

    private let maxIndex = 8

    
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setController(indexViewController(forPage: 0))
    }
    
    
    
    // MARK: Convenience
     
    private func index(forViewController viewController: UIViewController) -> Int {
        guard let viewController = viewController as? IndexViewController else {
            fatalError("Unexpected view controller type in page view controller.")
        }
        return viewController.index
    }
    
    private func indexViewController(forPage pageIndex: Int) -> IndexViewController {
        let identifier = String(describing: pageIndex) as NSString
        
        if let cachedController = indexViewControllerCache.object(forKey: identifier) {
            // Return the cached view controller.
            return cachedController
        }
        else {
            // Instantiate and configure a `DataItemViewController` for the `DataItem`.
            let controller = IndexViewController(pageIndex)
            
            // Cache the view controller so it can be reused.
            indexViewControllerCache.setObject(controller, forKey: identifier)
            
            // Return the newly created and cached view controller.
            return controller
        }
    }
 


    // MARK: - PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index < 1 {
            return indexViewController(forPage: maxIndex - 1)
        }
        return indexViewController(forPage: currentController.index - 1)
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index < maxIndex - 1 {
            return indexViewController(forPage: currentController.index + 1)
        }
        return indexViewController(forPage: 0)
    }
}
