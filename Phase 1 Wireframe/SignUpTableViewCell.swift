//
//  SignUpTableViewCell.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/24/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// The `GeneralUITableViewCell` objects that appear in the SignupTableView. This custom class has `IBOutlets` for buttons, labels, and text fields.
class SignUpTableViewCell: GeneralUITableViewCell {
    
    // MARK: - IBOutlets
    
    /// UIButton used for social media buttons.
    @IBOutlet weak var button: UIButton?
    /// Label inbetween buttons.
    @IBOutlet weak var label: UILabel?
    /// `CustomUITextField` where the user can specify email, phone number or password.
    @IBOutlet weak var textField: CustomUITextField?

}
