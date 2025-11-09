//
//  GeneralUITableView.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UITableView` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUITableView` objects
class GeneralUITableView: UITableView {

    // MARK: - Lifecycle
    
    /**
     Customize appearance of the `UITableView` object when this function is called. The theme enforces the seperatorStyle, estimatedRowHeight, allowsSelection and backgroundColor to be consistent among all `GeneralUITableView` objects.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Do any additional setup after awakening
        self.separatorStyle     = .none
        self.estimatedRowHeight = 200
        self.allowsSelection    = false
        self.backgroundColor    = UIColor.BACKGROUND
    }

}
