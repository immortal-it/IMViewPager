//
//  SampleHorizontalPageController.swift
//  Demo
//
//  Created by immortal on 2022/1/11
//

import Foundation

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
