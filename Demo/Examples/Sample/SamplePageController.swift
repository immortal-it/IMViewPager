//
//  SamplePageController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit
import IMViewPager
 
class SamplePageController: IMPageViewController, IMPageViewControllerDataSource {
     
    private let maxIndex = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        dataSource = self
        delegate = self
        setController(indexViewController(forPage: 0))
    }
    
    private func indexViewController(forPage pageIndex: Int) -> IndexViewController {
        IndexViewController(pageIndex)
    }



    // MARK: - PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index <= 0 {
            return indexViewController(forPage: maxIndex)
        }
        return indexViewController(forPage: currentController.index - 1)
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index >= maxIndex - 1 {
            return indexViewController(forPage: 0)
        }
        return indexViewController(forPage: currentController.index + 1)
    }
}



// MARK: - PageViewControllerDelegate

extension SamplePageController: IMPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: IMPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
         
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
         
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, didScrollAfter viewController: UIViewController, pendingViewController: UIViewController, progress: CGFloat) {
        print("didScrollAfter: ", progress)

    }
    
    func pageViewController(_ pageViewController: IMPageViewController, didScrollBefore viewController: UIViewController, pendingViewController: UIViewController, progress: CGFloat) {
         print("didScrollBefore: ", progress)
    }
}
