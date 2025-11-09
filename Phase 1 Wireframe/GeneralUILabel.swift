//
//  GeneralUILabel.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UILabel` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUILabel` objects
class GeneralUILabel: UILabel {

    // MARK: - Lifecycle
    
    /**
     Customize appearance of the `UILabel` object when this function is called. The theme enforces the text color and font. This will ensure that all `GeneralUILabel` objects will have the same appearance.

     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Do any additional setup after awakening
        self.textColor = UIColor.WHITE
        self.font      = UIFont.LABEL
    }

}
