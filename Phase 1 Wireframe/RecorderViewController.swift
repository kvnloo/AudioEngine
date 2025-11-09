//
//  RecorderViewController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CoreAudio

/// Controls the audio recording interface for the equalizer application.
///
/// This view controller manages the recording functionality, allowing users to capture
/// audio clips for later processing through the equalizer. It provides a simple
/// interface with record, pause, and stop controls.
///
/// The controller handles:
/// - Audio recording session management through `Audio` singleton
/// - UI state management for recording controls
/// - Delegate callbacks for recording completion
/// - Transition to the equalizer player after successful recording
///
/// - Note: Uses the `Audio` singleton for actual recording operations
/// - Important: Requires microphone permissions to be granted
/// - Note: Implements AVAudioRecorderDelegate protocol for recording lifecycle management
class RecorderViewController: GeneralUIViewController, AVAudioRecorderDelegate {

    // MARK: - IBOutlets
    
    /// The `UIButton` to start recording.
    @IBOutlet weak var recordButton: UIButton!
    /// The `UIButton` to stop recording.
    @IBOutlet weak var stopButton: UIButton!
    
    
    /// The `GeneralUILabel` that displays if in record mode.
    @IBOutlet weak var recordingLabel: GeneralUILabel!
    
    // MARK: - Global Variables
    /// The state of the recorder -> true if recording, false if paused or stopped.
    var state: Bool! // This will decide if the button should be a mic or the pause button
    
    // MARK: - GeneralUIViewController Methods
    
    /// Hide `stopButton` and `recordingLabel`. This must be done since the user should not be able to stop the recording before it even starts.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do any additional setup after calling super classes function
        stopButton.isHidden = true
        recordingLabel.isHidden = true
        
    }
    
    /// Set the state and font of the `recordingLabel`. Call `setupAVAudioSession` to initiate the recording process.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        state = true
        recordingLabel.font = UIFont.CAPTION
        
        // Setup Audio session
        Audio.sharedInstance.setupAVAudioSession()
        Audio.sharedInstance.recorderDelegate = self
    }
    
    /// Set the state so that it does not keep getting modified.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state = true
        recordButton.setImage(#imageLiteral(resourceName: "record-button"), for: .normal)
    }
    
    // MARK: Navigation
    
    /// Overridden to send `RecordedAudioObject` to the next `GeneralUIViewController` that we are seguing to. In this case the only possible segue is to `EqualizerViewController`.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        if segue.identifier == "SegueToEqualizerPlayer" {
//            let data = sender as! RecordedAudioObject
//            Audio.sharedInstance.recordedAudio = data
//        }
        
    }
    
    // MARK: AVAudioRecorderDelegate
    
    /// Ensures that when the recording ends a sucess or failure flag is sent to `recordingEnded` function.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            Audio.sharedInstance.recordingEndedSuccessfully()
            // Perform Segue to EqualizerPlayer
            self.performSegue(withIdentifier: "SegueToEqualizerPlayer", sender: Audio.sharedInstance.recordedAudio)
        } else {
            // Recording failed - user should be notified via UI alert
            print("RECORDING FAILED")
        }
    }
    
    // MARK: IBActions
    
    /// Toggle the state - this function handles the logic of switching the state as well as toggling the visibility for different views.
    @IBAction func toggleRecording(_ sender: UIButton) {
        stopButton.isHidden = false
        if state {
            Audio.sharedInstance.recorder?.record()
            state = false
            recordButton.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
            recordingLabel.isHidden = false
        } else {
            Audio.sharedInstance.recorder?.pause()
            state = true
            recordButton.setImage(#imageLiteral(resourceName: "record-button"), for: .normal)
            recordingLabel.isHidden = true
        }
        
    }
    
    /// Stops recording by invoking the `AVAudioRecorder's stop` method on `Audio.sharedInstance.recorder`.
    @IBAction func stopRecording(_ sender: UIButton) {
        Audio.sharedInstance.recorder?.stop()
    }
    
}
