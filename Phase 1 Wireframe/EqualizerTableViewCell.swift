//
//  EqualizerTableViewCell.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/29/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
import VerticalSlider

/// Custom `GeneralUITableViewCell` made for the EqualizerTableView. These cells contain `VerticalSlider` objects that allow the user to control gain on different frequencies for an equalizer.
class EqualizerTableViewCell: GeneralUITableViewCell {
    
    /// A `StackView` that contains 7 `VerticalSlider` objects.
    @IBOutlet weak var sliderStackView: UIStackView!
    /// A `StackView` that contains 7 `GeneralUILabel` objects.
    @IBOutlet weak var labelStackView: UIStackView!
    
    /// This property gets set by each cell's parent `GeneralUITableView`. When it gets set, the cell decides how to label the `VerticalSlider` objects and what color they will be. Calls `updateSelf`.
    var row: Int? {
        didSet {
            updateSelf()
        }
    }

    /// The section index for this cell in the table view, representing the audio channel (0 = left, 1 = right).
    ///
    /// This property is used in conjunction with `row` to calculate the correct index into the user's
    /// equalizer data array when loading saved gain values. The calculation follows the pattern:
    /// - For highs (row 0): `index = 7 + i + (section * 14)` where i is slider position 0-6
    /// - For lows (row 1): `index = i + (section * 14)` where i is slider position 0-6
    ///
    /// - Note: Must be set by the parent table view before cell configuration
    /// - Important: Valid values are 0 (left channel) or 1 (right channel)
    var section: Int?
    
    /// Sets the font for all `GeneralUILabel` objects. Also adds a target to each `VerticalSlider` that calls `EqualizerViewController.updateGains` which results in the equalizers pulling data from the `VerticalSlider` objects to set the different frequency's gain levels.
    override func awakeFromNib() {
        super.awakeFromNib()
        for label in labelStackView.subviews {
            (label as! GeneralUILabel).font = UIFont.EQUALIZER
        }
        for view in sliderStackView.subviews {
            let slider = view as! VerticalSlider
            slider.slider.addTarget(nil, action: #selector(EqualizerViewController.updateGains), for: .valueChanged)
        }
    }
    
    /// This function is invoked when `row` gets set by the parent `GeneralUITableView`. It sets the tint color for the `VerticalSlider` objects as well as the text for each `GeneralUILabel` based on the `row` value.
    func updateSelf() {
        let labels =  labelStackView.subviews
        if row == 0 {
            // highs
            sliderStackView.tintColor = UIColor.RED
            (labels[0] as! GeneralUILabel).text = "1kHz"
            (labels[1] as! GeneralUILabel).text = "2kHz"
            (labels[2] as! GeneralUILabel).text = "3kHz"
            (labels[3] as! GeneralUILabel).text = "4kHz"
            (labels[4] as! GeneralUILabel).text = "5kHz"
            (labels[5] as! GeneralUILabel).text = "10kHz"
            (labels[6] as! GeneralUILabel).text = "16kHz"
            
        } else {
            // lows
            sliderStackView.tintColor = UIColor.BLUE
            (labels[0] as! GeneralUILabel).text = "8Hz"
            (labels[1] as! GeneralUILabel).text = "16Hz"
            (labels[2] as! GeneralUILabel).text = "32Hz"
            (labels[3] as! GeneralUILabel).text = "64Hz"
            (labels[4] as! GeneralUILabel).text = "128Hz"
            (labels[5] as! GeneralUILabel).text = "256Hz"
            (labels[6] as! GeneralUILabel).text = "512Hz"
        }
        
        if let user = APIManager.sharedInstance.user, let data = user.data {
            let sliders = sliderStackView.subviews
            for i in 0...(sliders.count - 1) {
                let slider = sliders[i] as! VerticalSlider
                if row! == 0 {
                    slider.slider.value = data[i + 7 + section! * 14]
                } else {
                    slider.slider.value = data[i + section! * 14]
                }
            }
        }
    }
}
