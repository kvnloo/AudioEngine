//
//  RoundedButton.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/24/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UIButton` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUIButton` objects
class GeneralUIButton: UIButton {
    
    // MARK: - Lifecycle
    
    /**
     Customize appearance of the `UIButton` object when this function is called. The theme enforces the cornerRadius, backgroundColor, titleColor, and titleLabelFont to be consistent among all `GeneralUIButton` objects.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Do any additional setup after awakening
        self.clipsToBounds         = true
        self.layer.cornerRadius    = 20.0
        self.titleLabel?.font      = UIFont.BUTTON
        self.backgroundColor       = UIColor.GREEN
        self.setTitleColor(UIColor.BLACK, for: .normal)
    }

}
