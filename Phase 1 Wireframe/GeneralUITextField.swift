//
//  RoundedButton.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/24/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This type was created to ensure that all of the `UITextField` objects are created consistently. This class allows the developer to easily apply a 'theme' across all of the `GeneralUITextField` objects
class GeneralUITextField: UITextField {
    
    // MARK: - Lifecycle
    
    /**
     Customize appearance of the `UITextField` object when this function is called. The theme enforces the background, placeholder text, and typed in text colors. Furthermore, a specific font is applied to the text that appears in this `UITextField`. Background Color is set to `UIColor.CHARCOAL`. Placeholder Text Color is set to `UIColor.CREME`. Text Color is set to `UIColor.WHITE`. Font is set to `UIFont.TEXTFIELD`. This will ensure that all `GeneralUITextField` objects will have the same appearance.
     
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Do any additional setup after awakening
        self.backgroundColor       = UIColor.CHARCOAL
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: UIColor.CREME])
        self.textColor             = UIColor.WHITE
        self.font                  = UIFont.TEXTFIELD
        
    }

}
