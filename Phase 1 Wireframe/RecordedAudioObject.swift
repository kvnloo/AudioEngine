//
//  RecordedAudioObject.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/27/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
/**
    This is a custom model that stores both a URL and a title for an audio clip.

    The `RecordedAudioObject` encapsulates recorded audio file metadata, storing the absolute
    file path URL and the display title (derived from the filename). This object is created
    after successful recording and passed between view controllers for playback and processing.

    - SeeAlso: `Audio.recordingEndedSuccessfully()` for object initialization
 */
class RecordedAudioObject: NSObject {
    /// An absolute path to a given file.
    var filePathUrl: URL!
    /// The last component of the url, the name for the file.
    var title: String!
}
