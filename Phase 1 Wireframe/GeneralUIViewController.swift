//
//  GeneralViewController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UIViewController` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUIViewController` objects
class GeneralUIViewController: UIViewController {

    // MARK: - Lifecycle
    
    /**
     Customize appearance of the `UIViewController` object when this function is called. The theme enforces the background color as well as the appearance of the `navigationController` by calling `setBottomBorderColor` with `color (@param)` set to `UIColor.CREME` and `height (@param)` set to `0.25`. Finally it creates a new `UIBarButtonItem` such that the `Back Button` shows only an arrow to signifiy return.
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.BACKGROUND
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor.CREME, height: 0.25)
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
    }
}
