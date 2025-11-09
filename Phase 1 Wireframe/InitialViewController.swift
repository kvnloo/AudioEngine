//
//  InitialViewController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/** Controls the initial view with which the user is presented.
    
    The application checks user authentication state via `APIManager` singleton and responds to
    `NotificationCenter` notifications to navigate to appropriate screens (demo tools or login).
 */
class InitialViewController: GeneralUIViewController {

    // MARK: - IBOutlets
    
    /// A button for the user to create an account.
    @IBOutlet weak var createAccountButton: GeneralUIButton!
    /// A button for the user to login with existing credentails.
    @IBOutlet weak var logInButton: GeneralUIButton!
    /** A button to skip sign in and account creation to test the tools.
     
        - Note: this does not allow the user to save their preferences.
     */
    @IBOutlet weak var demoToolsButton: GeneralUIButton!
    /// An imageView that displays the company's logo.
    @IBOutlet weak var logoImageView: UIImageView!
    /// A label to display the company's name.
    @IBOutlet weak var logoLabel: GeneralUILabel!
    /// A label to ask the user if they would like to continue without signing in. This gets hidden if the user signs in.
    @IBOutlet weak var toolsPromptLabel: GeneralUILabel!
    /// A label to ask the user if they would like to log in. This gets hidden if the user signs in.
    @IBOutlet weak var loginPrompt: GeneralUILabel!
    
    // MARK: - UIViewController
    
    /// Configure UIElements of the view. This sets the colors for the different buttons and the tint color for the ImageViews. Includes logic for if the user is signed in or not.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        if let _ = APIManager.sharedInstance.user {
            logInButton.backgroundColor     = UIColor.RED
            logInButton.setTitle("LOG OUT", for: .normal)
            logInButton.removeTarget(nil, action: nil, for: .allEvents)
            logInButton.addTarget(self, action: #selector(self.requestLogout(_:)), for: .touchUpInside)
            createAccountButton.removeFromSuperview()
            toolsPromptLabel.removeFromSuperview()
            loginPrompt.removeFromSuperview()
            demoToolsButton.setTitle("TOOLS", for: .normal)
            
        } else {
            logInButton.backgroundColor     = UIColor.WHITE
        }
        demoToolsButton.backgroundColor = UIColor.WHITE
        logoImageView.tintColor         = UIColor.WHITE
        logoLabel.font                  = UIFont.LOGO
        logoLabel.textColor             = UIColor.WHITE
        
        
    }
    
    /// Hides the navigation bar since it would look strange in the initial view with which the user is presented.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Reshow the navigation bar since it is an important part of other views.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    // MARK: - IBActions
    
    /// An action method for when the user attempts to logout. This makes changes within the `APIManager` that set the user to nil and change the `rootViewController`.
    @IBAction func requestLogout(_ sender: Any) {
        APIManager.sharedInstance.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"initial")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchViewControllers(viewController: viewController)
    }
    
    
}
