//
//  EqualizerTabBarController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/31/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
/**
 This class controls the `TabBarController` that manages the 0th and 1st channel equalizer bands that the user can manipulate. This class ensures that the a view is instantiated for each of these channels. It also sets data for each of the instantiated view controllers since they need information regarding which channel each `GeneralUIViewController` will be handeling.
 */
class EqualizerTabBarController: UITabBarController {

    /// This function manages instantiating the two `GeneralUIViewController` objects that show up within the `UITabBar`. It also creates a new navigation item for itself since the navigation bars defined in each vc will not show up due to thier relationship with regard to this class. Once these `GeneralUIViewController` objects have been instantiated, they are assigned to the self property `.viewControllers`.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc0 = storyboard.instantiateViewController(withIdentifier: "channel0") as! EqualizerViewController
        let vc1 = storyboard.instantiateViewController(withIdentifier: "channel0") as! EqualizerViewController
        let rightButton = UIBarButtonItem(customView: vc0.mainButton)
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "EQAULIZER"
        vc0.title = "Channel 0"
        vc1.title = "Channel 1"
        vc0.channel1 = false
        vc1.channel1 = true
        self.viewControllers = [vc0, vc1]
    }
}
