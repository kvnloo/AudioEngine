//
//  CustomUITextField.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/24/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// This class was designed to allow the programmer to insert an `imageView` on the left side of a `GeneralUITextField`
@IBDesignable
class CustomUITextField: GeneralUITextField {
    
    // MARK: - IBInspectable
    
    /// This variable is the leftImage itself. When it is set, or changed, it calles `updateView`.
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    /// This `CGFloat` represents the padding between the `UIImageView` and the text.
    @IBInspectable var leftPadding: CGFloat = 0
    /// This `CGFloat` represents the width of the `UIImageView`.
    @IBInspectable var imageWidth: CGFloat = 20
    /** Tint color for the `UIImageView`. When this is set, `updateView` is called.
        note - in order for the image to visually change tintColor, it's "Render as" property in Assets.xcassets must be set to "Template Image".
    */
    @IBInspectable var color: UIColor = UIColor.WHITE {
        didSet {
            updateView()
        }
    }

    
    // MARK: - UITextField Methods
    
    /// This function moves the textField x-origin component of UITextField by `leftPadding`.
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    /// This method is overridden to set `leftViewMode` to `UITextFieldViewMode.always`.
    override func awakeFromNib() {
        super.awakeFromNib()

        // Do any additional setup after awakening
        self.leftViewMode     = UITextFieldViewMode.always
    }

    /// This function updates all of the views within the `UITextField` object. It creates insets for the UIImage provided in `leftImage` then sets the imageView as well as it's properties such as the `tintColor` and `contentMode`.
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: 20))
            imageView.image = image
            imageView.tintColor = color
            imageView.contentMode = .scaleAspectFit
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
    }
}
