//
//  NoiseMeterViewController.swift
//  Phase 1 Wireframe
//
//  Created by Kevin Rajan on 5/25/17.
//  Copyright © 2017 veeman961. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CoreAudio

/// A custom class that inherits from `GeneralUIViewController` and `AVAudioRecorderDelegate`. It was created to control the NoiseMeterView.
class NoiseMeterViewController: GeneralUIViewController,  AVAudioRecorderDelegate {
    
    // MARK: - IBOutlets
    
    /// A dynamic `GeneralUILabel` that displays the Noise Level.
    @IBOutlet weak var noiseLevelLabel: GeneralUILabel!
    /// A static `GeneralUILabel` that displays the dB Unit.
    @IBOutlet weak var dbLabel: GeneralUILabel!
    
    /// A static `GeneralUILabel` that captions the silent UIView.
    @IBOutlet weak var silentLabel: GeneralUILabel!
    /// A static `GeneralUILabel` that captions the quiet UIView.
    @IBOutlet weak var quietLabel: GeneralUILabel!
    /// A static `GeneralUILabel` that captions the average UIView.
    @IBOutlet weak var averageLabel: GeneralUILabel!
    /// A static `GeneralUILabel` that captions the noisy UIView.
    @IBOutlet weak var noisyLabel: GeneralUILabel!
    /// A static `GeneralUILabel` that captions the loud UIView.
    @IBOutlet weak var loudLabel: GeneralUILabel!
    
    /// A static `UIView` that is colored `UIColor.BLUE` to represent the 'silent' noise range.
    @IBOutlet weak var noiseMeterViewOne: UIView!
    /// A static `UIView` that is colored `UIColor.GREEN` to represent the 'quiet' noise range.
    @IBOutlet weak var noiseMeterViewTwo: UIView!
    /// A static `UIView` that is colored `UIColor.PURPLE` to represent the 'average' noise range.
    @IBOutlet weak var noiseMeterViewThree: UIView!
    /// A static `UIView` that is colored `UIColor.ORANGE` to represent the 'noisy' noise range.
    @IBOutlet weak var noiseMeterViewFour: UIView!
    /// A static `UIView` that is colored `UIColor.RED` to represent the 'loud' noise range.
    @IBOutlet weak var noiseMeterViewFive: UIView!
    
    // MARK: - Global Variables
    
    /// The recorder object on which the noise meter relies, configured via the `Audio` singleton's `AVAudioSession` and recorder setup.
    var recorder: AVAudioRecorder?
    /// A timer object to gathers noise data frequently.
    var levelTimer = Timer()
    /// An array to store the recorded noise levels. This can possibly be used to display a history graph of the past noise levels.
    var dBs: NSArray = NSArray()
    
    // MARK: - GeneralUIViewController Methods
    
    /// Calls `setupNoiseMeter` to color all of the `UIViews` to make them look like a legend for the `noiseLevelLabel`.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup UI Elements
        setupNoiseMeter()
    }
    /// This function sets up custom UI Elements specific to this view then calls `setupAVAudioSession` to set up the audio session that measures noise.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view:
        noiseLevelLabel.font = UIFont.LARGE
        dbLabel.font = UIFont.LARGE
        
        // Setup Audio Session
        setupAVAudioSession()
    }

    // MARK: - Logic
    
    /// Creates an `AVAudioSession` as a `sharedInstance` then requests recording permission from the user. If the user allows recording, the `AVAudioSession` has settings changed and the `record` method is called.
    func setupAVAudioSession() {
        //make an AudioSession and request recording permission
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { [unowned self] allowed in
            if allowed { // Microphone allowed, do what you like!
                
                // settings for a high-quality single-channel recording session
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                self.record(filename: "audioFileName.m4a", settings: settings, metered: true, timeIntervalForResults: 0.5)
            } else {
                // Microphone permission denied
                print("Failed to get recording permission")
            }
        }
    }
    
    /// A function that allows the `recorder` to record storing the file at `filename (@param)`, with settings `settings (@param)`, a flag to determine if the recording should be metered, and a timeInterval for `levelTimer`.
    func record(filename: String, settings: [String:Int], metered: Bool, timeIntervalForResults: TimeInterval) {
        // Get path for app directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioUrl = docsDirect.appendingPathComponent(filename)
        
        // create the session
        let session = AVAudioSession.sharedInstance()
        do {
            // configure the session for recording and playback
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            // create the audio recording, and assign ourselves as the delegate
            recorder = try AVAudioRecorder(url: audioUrl, settings: settings)
            recorder?.delegate = self
            recorder?.prepareToRecord()
            recorder?.isMeteringEnabled = metered
            recorder?.record()
            if metered {
                //instantiate a timer to be called with whatever frequency we want to grab metering values
                self.levelTimer = Timer.scheduledTimer(timeInterval: timeIntervalForResults, target: self, selector: #selector(NoiseMeterViewController.levelTimerCallback), userInfo: nil, repeats: true)
            }
        } 
        catch let error {
            print("recording failed...printing error: \n", error)
        }
    }
    
    /// The callback function for `levelTimer`. This allows the view to be updated with the new noise levels: `recorder` calls `updateMeters` and `updateLabels` is called to update the view.
    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
        recorder!.updateMeters()

        // print("channel 0: ", recorder!.averagePower(forChannel: 0))
        let dB = convertToDecibel(originalValue: recorder!.averagePower(forChannel: 0))
        updateLabels(dB: dB)
    }
    
    /// This function changes the text in the `noiseLevelLabel` and sets the color of the text based on the `NoiseMeterColors`.
    func updateLabels(dB: Float) {
        noiseLevelLabel.text = String(Int(dB))
        if dB < 50 {
            noiseLevelLabel.textColor = UIColor.BLUE
            dbLabel.textColor = UIColor.BLUE
        } else if dB < 75 {
            noiseLevelLabel.textColor = UIColor.GREEN
            dbLabel.textColor = UIColor.GREEN
        }  else if dB < 90 {
            noiseLevelLabel.textColor = UIColor.PURPLE
            dbLabel.textColor = UIColor.PURPLE
        } else if dB < 100 {
            noiseLevelLabel.textColor = UIColor.ORANGE
            dbLabel.textColor = UIColor.ORANGE
        }  else if dB < 120 {
            noiseLevelLabel.textColor = UIColor.RED
            dbLabel.textColor = UIColor.RED
        }
    }
    
    /// Converts from Apple standard noise levels to the universally used decibel system. Changes values from a linear [-160, 0] scale to a logrithmic [0, 120] scale.
    func convertToDecibel (originalValue: Float) -> Float {
        var level: Float
        let min:Float = -80.0
        
        if originalValue < min {
            level = 0.0
        } else if originalValue >= 0.0 {
            level = 1.0
        } else {
            let root:Float            = 2.0
            let minAmp:Float          = powf(10.0, 0.05 * min)
            let inverseAmpRange:Float = 1.0 / (1.0 - minAmp)
            let amp:Float             = powf(10.0, 0.05 * originalValue)
            let adjAmp:Float          = (amp - minAmp) * inverseAmpRange
            level                     = powf(adjAmp, 1.0 / root)
        }
        return level * 120
    }
    
    /// This function sets up the different small `UIViews` that create the NoiseMeter at the top of this `UIView`. Also sets the font for the labels that describe each color of the meter.
    func setupNoiseMeter() {
        noiseMeterViewOne.backgroundColor   = UIColor.BLUE
        noiseMeterViewTwo.backgroundColor   = UIColor.GREEN
        noiseMeterViewThree.backgroundColor = UIColor.PURPLE
        noiseMeterViewFour.backgroundColor  = UIColor.ORANGE
        noiseMeterViewFive.backgroundColor  = UIColor.RED
        silentLabel.font  = UIFont.CAPTION
        quietLabel.font   = UIFont.CAPTION
        averageLabel.font = UIFont.CAPTION
        noisyLabel.font   = UIFont.CAPTION
        loudLabel.font    = UIFont.CAPTION
    }
    
    // MARK: AVAudioRecorderDelegate
    
    /// Ensures that when the recording ends a sucess or failure flag is sent to `recordingEnded` function.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingEnded(success: flag)
    }
    
    /// Prints whether or not the recording session ended correctly.
    func recordingEnded(success: Bool) {
        if success {
            print("RECORDING SUCCEEDED")
        } else {
            print("RECORDING FAILED")
        }
    }
    
    
    
}
