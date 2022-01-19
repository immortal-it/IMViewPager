//
//  SamplePageController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit
import IMViewPager
 
class SamplePageController: IMPageViewController, IMPageViewControllerDataSource {
     
    private let maxIndex = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        dataSource = self
        setController(indexViewController(forPage: 0), animated: true)
    }
    
    func indexViewController(forPage pageIndex: Int) -> IndexViewController {
        IndexViewController(pageIndex)
    }



    // MARK: - PageViewControllerDataSource
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index < 1 {
            return nil
        }
        return indexViewController(forPage: currentController.index - 1)
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index < maxIndex - 1 {
            return indexViewController(forPage: currentController.index + 1)
        }
        return nil
    }
}


class SampleHorizontalPageController: SamplePageController {
     
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(.horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SampleVerticalPageController: SamplePageController {
     
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(.vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
