//
//  User.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/31/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit

/// Represents a user account within the JubiAudio application with authentication and data storage capabilities.
///
/// The User model supports multiple authentication methods and stores audio equalizer settings
/// for persistence across sessions. User data is synchronized with Firebase Realtime Database
/// to provide cross-device consistency.
///
/// **Authentication Methods:**
///
/// - **Email/Password**: Traditional Firebase authentication with username and password
/// - **Social OAuth**: Facebook and Google Sign-In via access tokens
///
/// **Data Storage:**
///
/// User equalizer settings (28 float values representing 14-band dual-channel EQ) are stored
/// in the `data` property and persisted to Firebase using a hash of the user's email as the key.
///
/// - Note: At least one authentication method must be used (uid/pw OR token)
/// - Important: The data array contains 28 float values: 14 bands × 2 channels (left/right)
/// - SeeAlso: APIManager for authentication flow and data synchronization
class User: NSObject {
    /// The username for a given user.
    var uid: String?
    /// The password for a given user.
    var pw: String?
    /// The token if using AUTH.
    var token: String?
    /// The data to be stored in the server.
    var data: [Float]?
    /// Determines if the user signed in with an email or a phone number
    var email: Bool?
    
    /// Initializer for the user object with a username, password, and a Boolean describing if using an email or phonenumber.
    init(uid: String?, pw: String, email: Bool?) {
        self.uid   = uid
        self.pw    = pw
        self.email = email
    }
    
    /// Initializes user with an API token that can be attained through social media login.
    init(token: String?) {
        self.token = token
    }
    
    /// A function that sets the data object of the user.
    func setData(data: [Float]?) {
        self.data  = data
    }

}
