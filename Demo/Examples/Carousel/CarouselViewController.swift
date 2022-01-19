//
//  CarouselViewController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit
import IMViewPager
 
class CarouselViewController: IMCarouselViewController, IMCarouselViewControllerDataSource {
     
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        isPageControlHidden = false
    }
    
    
    // MARK: IMCarouselViewControllerDataSource
    
    func numberOfItems(in carouselViewController: IMCarouselViewController) -> Int {
        8
    }
    
    func carouselViewController(_ carouselViewController: IMCarouselViewController, viewControllerForItemAt index: Int) -> UIViewController {
        IndexViewController(index)
    }
}


class ForwardCarouselViewController: CarouselViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        direction = .forward
    }
}

class ReverseCarouselViewController: CarouselViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        direction = .reverse
    }
}
