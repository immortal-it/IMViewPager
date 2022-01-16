//
//  TabPageViewController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit
import IMViewPager

class SegmentedPageViewController: UIViewController, IMPageViewControllerDataSource, IMPageViewControllerDelegate {
    
    private let indexViewControllerCache = NSCache<NSString, IndexViewController>()

    private let maxIndex = 5
    
    private let pageController = IMPageViewController(.horizontal)
    
    private let segmentedControl = UISegmentedControl(items: Array<Int>(repeating: 0, count: 5).enumerated().map({ $0.offset.description }))
    
    private let effectView: UIVisualEffectView = {
        if #available(iOS 13.0, *) {
            return UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        } else {
            return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
    }()

    

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
         
        loadSubviews()
        pageController.supportCache = false
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setController(indexViewController(forPage: 0))
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChangeValue(_:)), for: .valueChanged)
    }
    
    private func loadSubviews() {
        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageController.view)
        NSLayoutConstraint.activate([
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageController.didMove(toParent: self)
        
        effectView.layer.cornerRadius = 6.0
        effectView.layer.masksToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effectView)
        NSLayoutConstraint.activate([
            effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
            view.trailingAnchor.constraint(equalTo: effectView.trailingAnchor, constant: 12.0),
            effectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12.0),
            effectView.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        if #available(iOS 15.0, *) {
            segmentedControl.focusEffect = nil
        }
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .systemBlue
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor, constant: 5.0),
            segmentedControl.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor, constant: -5.0),
            segmentedControl.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: 5.0),
            segmentedControl.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -5.0)
        ])
    }
    
    @objc private func segmentedControlDidChangeValue(_ sender: UISegmentedControl) {
        if let currentController = pageController.currentController as? IndexViewController {
            pageController.setController(
                indexViewController(forPage: sender.selectedSegmentIndex),
                direction: currentController.index > sender.selectedSegmentIndex ? .reverse : .forward,
                animated: true
            )
        } else {
            pageController.setController(indexViewController(forPage: sender.selectedSegmentIndex))
        }
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
        if currentController.index <= 0 {
            return nil
        }
        return indexViewController(forPage: currentController.index - 1)
    }
    
    func pageViewController(_ pageViewController: IMPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentController = viewController as? IndexViewController else { return nil }
        if currentController.index >= maxIndex - 1 {
            return nil
        }
        return indexViewController(forPage: currentController.index + 1)
    }
 


    // MARK: - PageViewControllerDelegate

    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentController = pageViewController.currentController as? IndexViewController {
            segmentedControl.selectedSegmentIndex = currentController.index
        }
    }
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollAfter viewController: UIViewController,
        pendingViewController: UIViewController, progress: CGFloat
    ) {
        if progress == 1.0, let currentController = pendingViewController as? IndexViewController {
            segmentedControl.selectedSegmentIndex = currentController.index
        }
    }
    
    func pageViewController(
        _ pageViewController: IMPageViewController,
        didScrollBefore viewController: UIViewController,
        pendingViewController: UIViewController, progress: CGFloat
    ) {
        if progress == 1.0, let currentController = pendingViewController as? IndexViewController {
            segmentedControl.selectedSegmentIndex = currentController.index
        }
    }
}
