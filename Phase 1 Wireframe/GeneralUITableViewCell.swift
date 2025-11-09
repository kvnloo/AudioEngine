//
//  GeneralUITableViewCell.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UITableViewCell` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUITableViewCell` objects
class GeneralUITableViewCell: UITableViewCell {
    
    // MARK: - Lifecycle

    /**
     Customize appearance of the `UITableViewCell` object when this function is called. The theme enforces the backgroundColor to be consistent among all `GeneralUITableViewCell` objects.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.BACKGROUND
    }
}
