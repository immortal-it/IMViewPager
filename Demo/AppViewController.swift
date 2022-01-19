//
//  AppViewController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import UIKit

struct SectionModel {
     
    typealias Element = (title: String, viewControllerClass: UIViewController.Type)
    
    let title: String
    
    let elements: [Element]
}

class AppViewController: UITableViewController {
    
    let sectionModels: [SectionModel] = [
        SectionModel(title: "Navigation Orientation", elements: [
            ("Horizontal", SampleHorizontalPageController.self),
            ("Vertical", SampleVerticalPageController.self),
            ("Cache", CachedPageController.self)
        ]),
        SectionModel(title: "Carousel", elements: [
            ("Forward", ForwardCarouselViewController.self),
            ("Reverse", ReverseCarouselViewController.self)
             
        ]),
        SectionModel(title: "Segment", elements: [
            ("SegmentedPage", SegmentedPageController.self)
        ])
    ]
    
    let cellClass = UITableViewCell.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        title = "演示项目"
        tableView.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        tableView.tableFooterView = UIView()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModels[section].elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath)
        cell.textLabel?.text = sectionModels[indexPath.section].elements[indexPath.item].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let viewController = sectionModels[indexPath.section].elements[indexPath.item].viewControllerClass.init()
        navigationController?.pushViewController(viewController, animated: true)
        navigationItem.backButtonTitle = ""
        if #available(iOS 13.0, *) {
            viewController.view.backgroundColor = .systemBackground
        } else {
            viewController.view.backgroundColor = .white
        }
        viewController.title = sectionModels[indexPath.section].elements[indexPath.item].title
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionModels[section].title
    }
}
