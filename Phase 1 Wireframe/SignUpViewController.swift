//
//  SignUpViewController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/24/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
import FacebookLogin
/** This `GeneralUIViewController` controls the sign up view. It allows the user to create an account through Facebook, Google, E-mail, or Phone.
 
 Uses Firebase Authentication for account creation with support for:
 - Email/Password registration
 - Facebook OAuth registration (via `FBSDKLoginKit`)
 - Google Sign-In registration (via `GoogleSignIn SDK`)

 Input validation and API communication are handled through the `APIManager` singleton.
 
 */
class SignUpViewController: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    
    /// This table view sets up simple scrolling and reusable cells to simplify view layouts. This solution is more elegant than implementing a scroll view.
    @IBOutlet weak var tableView: GeneralUITableView!
    
    // MARK: - UIViewController
    
    /// Setup the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.userCreated), name: APIManager.sharedInstance.initialNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLoggedIn), name: APIManager.sharedInstance.demoNotification, object: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    /// Returns the number of sections in this tableView.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Returns the height of a given cell based on indexPath.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return 16
        default:
            return 66
        }
    }
    
    /// Returns the number of rows in this tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    /// Returns the cell using a reusable identifier based on the indexPath.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SignUpTableViewCell
        switch indexPath.row {
        case 0:
            cell                          = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! SignUpTableViewCell
            cell.button?.backgroundColor  = UIColor.FB_BLUE
            cell.button?.setTitleColor(UIColor.WHITE, for: .normal)
            cell.button?.setTitle("SIGN UP WITH FACEBOOK", for: .normal)
            cell.button?.addTarget(self, action: #selector(self.fbLoginButtonClicked), for: .touchUpInside)
            
        case 1:
            cell                          = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! SignUpTableViewCell
            cell.button?.backgroundColor  = UIColor.GOOGLE_RED
            cell.button?.setTitleColor(UIColor.WHITE, for: .normal)
            cell.button?.setTitle("SIGN UP WITH GOOGLE", for: .normal)
            cell.button?.addTarget(self, action: #selector(self.googleLoginButtonClicked), for: .touchUpInside)
        case 2:
            cell             = tableView.dequeueReusableCell(withIdentifier: "LabelCell") as! SignUpTableViewCell
            cell.label?.text = "or with e-mail / phone number"
            
        case 3:
            cell                        = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SignUpTableViewCell
            cell.textField?.leftImage   = UIImage(named: "ic_email_phone_white")
            cell.textField?.imageWidth  = 44
            cell.textField?.leftPadding = 10
            cell.textField?.placeholder = "E-mail Address or Phone Number"
            cell.textField?.text        = ""

            
        case 4:
            cell                        = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SignUpTableViewCell
            cell.textField?.leftImage   = UIImage(named: "ic_lock_white")
            cell.textField?.imageWidth  = 44
            cell.textField?.leftPadding = 10
            cell.textField?.placeholder = "Password"
            cell.textField?.text        = ""
            
            
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! SignUpTableViewCell
            cell.button?.setTitle("SIGN UP", for: .normal)
            cell.button?.addTarget(self, action: #selector(self.signupWithCredentials(_:)), for: .touchUpInside)
        case 6:
            cell             = tableView.dequeueReusableCell(withIdentifier: "LabelCell") as! SignUpTableViewCell
            cell.label?.text = "By signing up, you agree to JubiAudio's Terms and conditions of Use and Privacy Policy"
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! SignUpTableViewCell
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    /// Unselects a row after it is selected by the user. This tableview does not need selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Helper functions
    
    /// Returns the username that was typed in by the user.
    func getuid() -> String? {
        let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SignUpTableViewCell
        return cell.textField?.text
    }
    /// Returns the password that was typed in by the user.
    func getpw() -> String? {
        let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! SignUpTableViewCell
        return cell.textField?.text
    }
    
    /// Changes the rootViewController once the user has been created.
    func userCreated() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let newvc = storyboard.instantiateViewController(withIdentifier: "initial") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchViewControllers(viewController: newvc)
    }
    
    /// Changes the rootViewController once if the user logs in through social media.
    func userLoggedIn() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let newvc = storyboard.instantiateViewController(withIdentifier: "initial") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchViewControllers(viewController: newvc)
        newvc.childViewControllers[0].performSegue(withIdentifier: "initialToDemo", sender: Any?.self)
    }
    // MARK: - IBAction
    
    /// An action item for when the Facebook Login Button is clicked.
    @IBAction func fbLoginButtonClicked(sender: AnyObject) {
        APIManager.sharedInstance.vc = self
        APIManager.sharedInstance.fbSignIn()
    }
    /// An action item for when the Google Login Button is clicked.
    @IBAction func googleLoginButtonClicked(sender: AnyObject) {
        APIManager.sharedInstance.vc = self
        APIManager.sharedInstance.googleSignIn()
    }
    /// This function takes the information provided in this view's `CustomUITextField` objects and sends the information to `Firebase` to attempt logging in. Any failure messages are shown to the user as a notification.
    @IBAction func signupWithCredentials(_ sender: Any) {
        print("in action")
        if let username = getuid(), let password = getpw() {
            if username.contains("@") {
                APIManager.sharedInstance.user = User(uid: username, pw: password, email: true)
                
            } else {
                APIManager.sharedInstance.user = User(uid: "\(username)@test.com", pw: password, email: true)
            }
            APIManager.sharedInstance.vc = self
            APIManager.sharedInstance.createUser()
        }
    }

    
    
}
