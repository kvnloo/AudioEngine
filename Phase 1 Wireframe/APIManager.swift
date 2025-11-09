//
//  APIManager.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/30/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import GoogleSignIn

/// Manages user authentication and session state for the application.
///
/// This singleton class handles:
/// - Firebase authentication with email/password
/// - Social login integration (Facebook and Google)
/// - User session management
/// - Data persistence to Firebase Realtime Database
/// - Alert presentation for authentication feedback
///
/// - Note: This class requires Firebase to be configured in `AppDelegate` before use
/// - Important: Google Sign-In and Facebook Login must be properly configured in Info.plist
class APIManager: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    
    /// The currently authenticated user object containing user credentials and data
    var user: User?

    /// Notification name for transitioning back to the initial view controller after logout or account creation
    let initialNotification = Notification.Name("PresentInitialViewController")

    /// Notification name for transitioning to the demo/main app view controller after successful authentication
    let demoNotification    = Notification.Name("PresentDemoViewController")

    /// Reference to the presenting view controller used for displaying alerts and authentication UI
    /// - Warning: Must be set before calling authentication methods that present UI
    var vc: UIViewController!

    /// Firebase Realtime Database reference for storing and retrieving user data
    var ref: DatabaseReference = Database.database().reference()

    /// Shared singleton instance of the API manager
    /// - Note: Access this property instead of creating new instances
    static let sharedInstance = APIManager()

    /// Creates a new user account with Firebase Authentication using email and password.
    ///
    /// This method uses the credentials stored in the `user` property to create a new Firebase account.
    /// After successful account creation, it displays a notification prompting the user to sign in
    /// and posts a notification to transition back to the initial view controller.
    ///
    /// - Precondition: The `user` property must be set with valid `uid` (email) and `pw` (password) values
    /// - Note: This method clears the `user` property after the operation completes (success or failure)
    /// - Important: Account creation does not automatically sign in the user
    func createUser() {
        if let user = user, let uid = user.uid, let pw = user.pw {
            Auth.auth().createUser(withEmail: uid, password: pw) { (user, error) in
                if let error = error {
                    self.presentNotification(title: "Error", message: error.localizedDescription, actionTitle: "Ok")
                    self.user = nil
                    return
                }
                self.presentNotification(title: "Account created successfully", message: "Now sign-in to use your account!", actionTitle: "Ok")
                self.user = nil
                NotificationCenter.default.post(name:self.initialNotification, object: nil)
            }
        }
        
    }

    /// Signs in an existing user with Firebase Authentication using email and password.
    ///
    /// This method authenticates the user using the credentials stored in the `user` property.
    /// Upon successful sign-in, it loads the user's data from Firebase, displays a success notification,
    /// and posts a notification to transition to the demo/main view controller.
    ///
    /// - Precondition: The `user` property must be set with valid `uid` (email) and `pw` (password) values
    /// - Note: This method clears the `user` property if authentication fails
    /// - SeeAlso: `createUser()` for account creation
    func signIn() {
        if let user = user, let uid = user.uid, let pw = user.pw {
            Auth.auth().signIn(withEmail: uid, password: pw) { (user, error) in
                if let error = error {
                    self.presentNotification(title: "Error", message: error.localizedDescription, actionTitle: "Ok")
                    self.user = nil
                    return
                }
                self.loadData()
                self.presentNotification(title: "Sign-in successful", message: "You may now continue using the application and your data will be saved online!", actionTitle: "Ok")
                NotificationCenter.default.post(name:self.demoNotification, object: nil)
            }
        }
    }

    /// Authenticates a user using Facebook Login SDK and Firebase Authentication.
    ///
    /// This method initiates the Facebook login flow, requesting email permissions.
    /// Upon successful Facebook authentication, it creates Firebase credentials using the Facebook access token
    /// and signs the user into Firebase. The user's data is then loaded and a notification is posted
    /// to transition to the demo/main view controller.
    ///
    /// - Note: Requires Facebook Login SDK to be properly configured in Info.plist
    /// - Important: The app must be registered with Facebook and have a valid App ID
    /// - SeeAlso: `googleSignIn()` for Google authentication
    func fbSignIn() {
        let loginManager = LoginManager()
        loginManager.logIn([.email], viewController: nil) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.presentNotification(title: "Error", message: error.localizedDescription, actionTitle: "Ok")
            case .cancelled:
                self.presentNotification(title: "User cancelled login.", message: "", actionTitle: "Ok")
            case .success( _, _, _):
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    self.user = User(token: FBSDKAccessToken.current().tokenString)
                    self.presentNotification(title: "Sign-in successful", message: "You may now continue using the application and your data will be saved online!", actionTitle: "Ok")
                    NotificationCenter.default.post(name:self.demoNotification, object: nil)
                    self.loadData()
                }
                
            }
        }
    }

    /// Initiates the Google Sign-In authentication flow.
    ///
    /// This method triggers the Google Sign-In process, which will present the Google authentication UI.
    /// The actual authentication handling is done in the delegate methods `sign(_:didSignInFor:withError:)`.
    ///
    /// - Note: Requires Google Sign-In SDK to be properly configured with a valid GoogleService-Info.plist
    /// - Important: The `vc` property must be set to present the Google Sign-In UI
    /// - SeeAlso: `sign(_:didSignInFor:withError:)` for authentication completion handling
    func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }

    /// Handles the result of a Google Sign-In attempt.
    ///
    /// This delegate method is called when the Google Sign-In process completes.
    /// If successful, it creates Firebase credentials from the Google authentication tokens
    /// and signs the user into Firebase. Upon successful Firebase authentication,
    /// user data is loaded and a notification is posted to transition to the demo view.
    ///
    /// - Parameters:
    ///   - signIn: The Google Sign-In instance
    ///   - user: The authenticated Google user object containing authentication tokens
    ///   - error: An error object if sign-in failed, nil if successful
    ///
    /// - Note: This is a GIDSignInDelegate method that must be implemented
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            APIManager.sharedInstance.presentNotification(title: "Error", message: error.localizedDescription, actionTitle: "Ok")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                APIManager.sharedInstance.presentNotification(title: "Error", message: error.localizedDescription, actionTitle: "Ok")
                return
            }
            APIManager.sharedInstance.user = User(token: authentication.accessToken)
            APIManager.sharedInstance.presentNotification(title: "Sign-in successful", message: "You may now continue using the application and your data will be saved online!", actionTitle: "Ok")
            NotificationCenter.default.post(name:APIManager.sharedInstance.demoNotification, object: nil)
            self.loadData()
        }
    }

    /// Handles when a user disconnects their Google account from the app.
    ///
    /// This delegate method is called when the user revokes access to their Google account.
    /// Can be used to perform cleanup operations such as clearing cached user data
    /// or updating the UI to reflect the disconnected state.
    ///
    /// - Parameters:
    ///   - signIn: The Google Sign-In instance
    ///   - user: The Google user that was disconnected
    ///   - error: An error object if the disconnect failed
    ///
    /// - Note: Currently not implemented but provided for GIDSignInDelegate conformance
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    /// Presents the Google Sign-In view controller.
    ///
    /// This delegate method is called when Google Sign-In needs to present its authentication UI.
    /// The implementation should present the provided view controller to the user.
    ///
    /// - Parameters:
    ///   - signIn: The Google Sign-In instance
    ///   - viewController: The view controller to present for authentication
    ///
    /// - Important: The `vc` property must be set to a valid UIViewController for this to work
    /// - Note: This is a GIDSignInUIDelegate method
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        vc.present(viewController, animated: true, completion: nil)
    }
    
    /// Dismisses the Google Sign-In view controller.
    ///
    /// This delegate method is called when Google Sign-In needs to dismiss its authentication UI,
    /// typically after the user has completed or cancelled the authentication flow.
    ///
    /// - Parameters:
    ///   - signIn: The Google Sign-In instance
    ///   - viewController: The view controller to dismiss
    ///
    /// - Note: This is a GIDSignInUIDelegate method
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        vc.dismiss(animated: true, completion: nil)
    }

    /// Saves the current user's data to Firebase Realtime Database.
    ///
    /// This method persists the user's data array to Firebase using a hashed version
    /// of their email address as the database key. The data is stored as an NSArray
    /// in the Firebase database for later retrieval.
    ///
    /// - Precondition: The `user` property must be set with valid data to save
    /// - Note: Uses the hash value of the user's email as the database node identifier
    /// - Important: Data is only saved if both user and data properties are non-nil
    func saveData() {
        if let user = user, let data = user.data as NSArray? {
            let hash = String(describing: user.uid?.hashValue)
            self.ref.setValue(hash)
            self.ref.child(hash).setValue(data)
        }
    }

    /// Loads the current user's data from Firebase Realtime Database.
    ///
    /// This method retrieves the user's previously saved data from Firebase using
    /// the hashed email address as the database key. The data is loaded asynchronously
    /// and stored in the user object's data property.
    ///
    /// - Precondition: The `user` property must be set to identify which data to load
    /// - Note: Uses a single value event observer to fetch data once
    /// - Important: The loaded data is cast to [Float] array format
    func loadData() {
        if let user = user {
            let hash = String(describing: user.uid?.hashValue)
            self.ref.child(hash).observeSingleEvent(of: .value, with: { (snapshot) in
                user.data = snapshot.value as? NSArray as? [Float]
                return
            })
        }
    }

    /// Logs out the current user by clearing the user session.
    ///
    /// This method performs a simple logout by setting the user property to nil,
    /// effectively clearing the cached user data and credentials from memory.
    ///
    /// - Note: This does not sign out from Firebase Auth or social providers
    /// - Important: Consider calling Firebase's `Auth.auth().signOut()` for complete logout
    public func logout() {
        user = nil
    }

    /// Presents a UIAlertController with the specified title, message, and action button.
    ///
    /// This utility method displays feedback to the user through a standard iOS alert dialog.
    /// It's used throughout the authentication flow to show success messages, errors,
    /// and other important notifications to the user.
    ///
    /// - Parameters:
    ///   - title: The title text displayed at the top of the alert
    ///   - message: The descriptive message body of the alert
    ///   - actionTitle: The text for the dismissal button (typically "Ok")
    ///
    /// - Important: Requires the `vc` property to be set to a valid UIViewController
    /// - Note: The alert is presented with a single default action that dismisses the alert
    func presentNotification(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
        self.vc.present(alert, animated: true, completion: nil)
    }
}
