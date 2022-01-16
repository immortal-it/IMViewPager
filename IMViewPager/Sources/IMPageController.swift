//
//  IMPageController.swift
//  IMViewPager
//
//  Created by immortal on 2021/8/9
//

import UIKit

class IMPageController {
    
    let viewController: UIViewController
            
    let containerView = UIView()
    
    var number: Int
    
    init(_ viewController: UIViewController, number: Int) {
        self.viewController = viewController
        self.number = number
    }
    
    deinit {
        removeFromParent()
    }
    
    var identifier: String {
        Self.asIdentifier(number)
    }
    
    var isVisible: Bool {
        containerView.superview !== nil
    }
    
    func addToParent(_ pageViewController: IMPageViewController, in parentView: UIView) {
        containerView.frame = CGRect(origin: .zero, size: parentView.bounds.size)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.isUserInteractionEnabled = true
        parentView.addSubview(containerView)
        
        pageViewController.addChild(viewController)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: pageViewController)
    }
    
    func removeFromParent() {
        containerView.removeFromSuperview()
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    static func asIdentifier(_ number: Int) -> String {
        "\(number)"
    }
}
