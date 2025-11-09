//
//  GeneralUIColor.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/**
    `GeneralUIColor.swift` is an extension on the UIColor class that defines the colors shown in the color palette generated for this application. It also includes colors for "Facebook Blue" and "Google+ Red". These are used for social media buttons with `GeneralUIButton` on the Login and Create Account view controllers.

     - Note: Many of the colors in storyboard are not accurate since the colors are later set using these definitions.
     - SeeAlso: `GeneralUIButton`, `GeneralUILabel`, `GeneralUITextField`, `GeneralUIViewController` for UI components using this palette

 */
public extension UIColor {
    
    // MARK: Palette Slate Colors
    
    /** Defined as `Isabelline` in the color palette. This is the lightest color that is used for most text. The following values are this color's representation in various color spaces:
     
        HEX:  #edeeef
        RGB:  237 238 239
        HSV:  210 1 94
        CMYK: 1 0 0 6
    */
    public class var WHITE: UIColor {
        return UIColor(red: 237/255, green: 238/255, blue: 239/255, alpha: 1.0)
    }
    
    /** Defined as `Silver Chalice` in the color palette. This is the next color after `Isabelline` and is used as a highlight color for the `UINavigationBar` as well as heading text (i.e. large text). The following values are this color's representation in various color spaces:
     
        HEX:  #a8aeaf
        RGB:  168 174 175
        HSV:  189 4 69
        CMYK: 4 1 0 31
    */
    public class var CREME: UIColor {
        return UIColor(red: 168/255, green: 174/255, blue: 175/255, alpha: 1.0)
    }
    
    /** Defined as `Outter Space` in the color palette. This is the next color after `Silver Chalice` and is used as the background color for `GeneralUITextField`. The following values are this color's representation in various color spaces:
     
        HEX:  #414E51
        RGB:  65 78 81
        HSV:  191 20 32
        CMYK: 20 4 0 68
    */
    public class var CHARCOAL: UIColor {
        return UIColor(red: 65/255, green: 78/255, blue: 81/255, alpha: 1.0)
    }
    
    /** Defined as `Gunmetal` in the color palette. This is the next color after `Outter Space` and is used as the background color for all of the `UIViews` in `UIViewControllers` of type `GeneralUIViewController`. The following values are this color's representation in various color spaces:
    
        HEX:  #282d34
        RGB:  40 45 52
        HSV:  215 23 20
        CMYK: 23 13 0 80
    */
    public class var BACKGROUND: UIColor {
        return UIColor(red: 40/255, green: 45/255, blue: 52/255, alpha: 1.0)
    }
    
    /** Defined as `Raisin Black` in the color palette. This is the next color after `Gunmetal` and is used as the text color `GeneralUILabel` found on light backgrounds or more particularly for the `LoginButton` found on the main page of this application. The following values are this color's representation in various color spaces:
        
        HEX:  #1d2025
        RGB:  29 32 37
        HSV:  218 22 15
        CMYK: 22 14 0 85
    */
    public class var BLACK: UIColor {
        
        return UIColor(red: 29/255, green: 32/255, blue: 37/255, alpha: 1.0)
    }

    // MARK: Palette Highlight Colors
    
    /** Defined as `Light Red Ochire` in the color palette. This color replaces all `Red` in the application. It can be used as a `GeneralUIButton` color, or `UIView`. This can be seen in the `NoiseMeter` where this color indicates the loudest audio decibal range. The following values are this color's representation in various color spaces:
    
        HEX:  #ea6552
        RGB:  234 101 82
        HSV:  8 65 92
        CMYK: 0 57 65 8
    */
    public class var RED: UIColor {
        return UIColor(red: 234/255, green: 101/255, blue: 82/255, alpha: 1.0)
    }
    
    /** Defined as `Very Light Malachite Green` in the color palette. This color replaces all `Green` in the application. It can be used as a `GeneralUIButton` color, or `UIView`. This can be seen in the `NoiseMeter` where this color indicates an audio decibal range. The following values are this color's representation in various color spaces:
        
        HEX:  #58e69a
        RGB:  88 230 154
        HSV:  148 62 90
        CMYK: 62 0 33 10
    */
    public class var GREEN: UIColor {
        return UIColor(red: 88/255, green: 230/255, blue: 154/255, alpha: 1.0)
    }
    
    /** Defined as `Pale Violet` in the color palette. This color replaces all `Purple` in the application. It can be used as a `GeneralUIButton` color, or `UIView`. This can be seen in the `NoiseMeter` where this color indicates an audio decibal range. The following values are this color's representation in various color spaces:
     
        HEX:  #d0a5ff
        RGB:  208 165 255
        HSV:  269 35 100
        CMYK: 18 35 0 0
     */
    public class var PURPLE: UIColor {
        return UIColor(red: 208/255, green: 165/255, blue: 255/255, alpha: 1.0)
    }
    
    /** Defined as `Maya Blue` in the color palette. This color replaces all `Blue` in the application. It can be used as a `GeneralUIButton` color, or `UIView`. This can be seen in the `NoiseMeter` where this color indicates an audio decibal range. The following values are this color's representation in various color spaces:
     
        HEX:  #7cc6fe
        RGB:  124 198 254
        HSV:  206 51 100
        CMYK: 51 22 0 0
    */
    public class var BLUE: UIColor {
        return UIColor(red: 124/255, green: 198/255, blue: 254/255, alpha: 1.0)
    }
    
    /** Defined as `Macaroni and Cheese` in the color palette. This color replaces all `Orange` in the application. It can be used as a `GeneralUIButton` color, or `UIView`. This can be seen in the `NoiseMeter` where this color indicates an audio decibal range. The following values are this color's representation in various color spaces:
     
        HEX:  #ffc689
        RGB:  255 198 137
        HSV:  31 46 100
        CMYK: 0 22 46 0
     */
    public class var ORANGE: UIColor {
        return UIColor(red: 255/255, green: 198/255, blue: 137/255, alpha: 1.0)
    }
    
    // MARK: Social Media Button Colors
    
    /** This is the official color designated by Facebook as their Facebook-Blue. This color was used as the background for the custom Facebook `GeneralUIButton` that shows up on the Login and Create Account `ViewControllers`. The following values are this color's representation in various color spaces:
    
        HEX:  #3b5998
        RGB:  59 89 152
        HSV:  221 61 60
        CMYK: 61 41 0 40
    */
    public class var FB_BLUE: UIColor {
        return UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
    }
    
    /** This is the official color designated by Google as their Google-Red. This color was used as the background for the custom Google `GeneralUIButton` that shows up on the Login and Create Account `ViewControllers`. The following values are this color's representation in various color spaces:
    
        HEX:  #dd4b39
        RGB:  221 75 57
        HSV:  7 74 87
        CMYK: 0 66 74 13
    */
    public class var GOOGLE_RED: UIColor {
        return UIColor(red: 221/255, green: 75/255, blue: 57/255, alpha: 1.0)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
}
