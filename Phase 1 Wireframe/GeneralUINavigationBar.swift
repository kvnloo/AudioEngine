//
//  GeneralUINavigationBar.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit


/// Extension created to allow the developer to modify the 'bottom border' of the `GeneralUINavigationBar`. This allows for the white highlight under the `GeneralUINavigationBar`
extension UINavigationBar {
    
    /// Creates a 'bottom border' for the `UINavigationBar` by creating a new `UIView` of height `height (@param)`, setting its background color to `color (@param)` adding it as a subview.
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}
