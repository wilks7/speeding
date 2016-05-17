//
//  ViewController.swift
//  speeding
//
//  Created by wilksmac on 5/16/16.
//  Copyright © 2016 wilksmac. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    let fileName = "demo.m4a"
    
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        if audioRecorder == nil {
            startRecording()
        }
        else {
            mphLabel.textColor = UIColor.whiteColor()
            finishRecording(success: true)
        }
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        playRecording()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }//viewdidload
    
    
    // FUNCTIONS: - Audio Recording
    
    func setupSession(){
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        print("Got persmission")
                    } else {
                        print("Didnt get permission")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
    }
    
    func startRecording() {

        let audioUrl = getFileURL()
        
        let maxSettings = [//filename should be .caf
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVSampleRateKey : 44100.0
        ]
        
        let smallSettings = [//filename should be .m4a
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioUrl, settings: smallSettings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            mphLabel.textColor = UIColor.redColor()
            buttonLabel.setTitle("STOP", forState: .Normal)
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        mphLabel.textColor = UIColor.whiteColor()

        
        if success {
            buttonLabel.setTitle("RE-RECORD", forState: .Normal)
        } else {
            buttonLabel.setTitle("RECORD", forState: .Normal)
            let alert = UIAlertController(title: "Recording Failed", message: "There was a problem saving the recording, it could be a space issue", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(okButton)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func playRecording(){
        let url = getFileURL()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: ".m4a")
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 5.0
            audioPlayer.play()
            
        } catch {
            ////finishRecording(success: false)
            print("Cant find file")
        }
    }
    
    // File Helpers
    
    func getCacheDirectory() -> AnyObject {
        
        let paths = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)
        return paths[0]
    }
    
    func getFileURL() -> NSURL {
        
        let path = getCacheDirectory().stringByAppendingPathComponent(fileName)
        let filePath = NSURL(fileURLWithPath: path)
        
        return filePath
    }

    
}//class

extension CLLocation {
    var coordinates: [String:Double] {
        
        var coord = [String : Double]()
        let lat = self.coordinate.latitude
        let lon = self.coordinate.longitude
        coord["latitude"] = lat
        coord["longitude"] = lon
        
        return coord
    }
}


