//
//  ColorPallete.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/**
 `GeneralUIFont.swift` is an extension on the UIFont class that defines different fonts to use in specific scenarios. This ensures consistency among `GeneralUILabel` objects, `GeneralUITextField` objects, and `UIButton` objects.
 */
extension UIFont {
    
    /// This is the default font that is used by `GeneralUIButton` objects.
    public class var BUTTON: UIFont {
        return UIFont(name: "Roboto-Medium", size: 15.0)!
    }
    
    /// This is the default font that is used by `GeneralUILabel` objects.
    public class var LABEL: UIFont {
        return UIFont(name: "Roboto-Regular", size: 12.0)!
    }
    
    /// This is the default font that is used by `GeneralUITextField` objects.
    public class var TEXTFIELD: UIFont {
        return UIFont(name: "Roboto-Bold", size: 14.0)!
    }
    
    /// This is the font that is used by text that appears under the logo on the `InitialViewController`
    public class var LOGO: UIFont {
        return UIFont(name: "Roboto-Black", size: 40.0)!
    }
    
    /// This is the font that is used by `NoiseMeterViewController` to display the Noise Level in decibels.
    public class var LARGE: UIFont {
        return UIFont(name: "Roboto-Black", size: 48.0)!
    }
    
    /// This is the font that is used by `NoiseMeterViewController` to caption the different colors in the Noise Meter.
    public class var CAPTION: UIFont {
        return UIFont(name: "Roboto-Light", size: 12.0)!
    }
    
    /// This is the font that is used by `EqualizerViewController` to display the different band frequencies.
    public class var EQUALIZER: UIFont {
        return UIFont(name: "Roboto-Black", size: 14.0)!
    }
}
