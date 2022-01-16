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
        dataSource = self
        super.viewDidLoad()
    }
    
    
    // MARK: IMCarouselViewControllerDataSource
    
    func numberOfItems(in carouselViewController: IMCarouselViewController) -> Int {
        5
    }
    
    func carouselViewController(_ carouselViewController: IMCarouselViewController, viewControllerForItemAt index: Int) -> UIViewController {
        IndexViewController(index)
    }
}
