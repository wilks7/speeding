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
    var locationManager = CLLocationManager()

    let fileName = "demo.m4a"
    
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var mphTextLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var playButtonLabel: UIButton!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        if audioRecorder == nil {
            startRecording()
        }
        else {
            finishRecording(success: true)
        }
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        //playRecording()
        do {
        let result = try String(contentsOfURL: getFileURL("log.txt"))
        print(result)

        } catch {
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if audioRecorder == nil {
            startRecording()
        }
        else {
            finishRecording(success: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSetup()
        setupSession()
        setupLocationManager()
    }//viewdidload
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationSettings()
    }
    
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func buttonSetup(){
        buttonLabel.hidden = true
        //playButtonLabel.hidden = true
        mphLabel.font = UIFont(name: "DBLCDTempBlack", size: 150.0)
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            mphLabel.text = "--"
            mphTextLabel.hidden = true
        }
    }
    
    func checkLocationSettings(){
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            print("Authorized location for all")
        case .NotDetermined:
            print("Requesting permisions....")
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            backgroundAlert()
        }
    }
    
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

        let audioUrl = getAudioURL()
        
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
            mphTextLabel.textColor = UIColor.redColor()
            buttonLabel.setTitle("STOP", forState: .Normal)
            print("...recording...")
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        mphLabel.textColor = UIColor.whiteColor()
        mphTextLabel.textColor = UIColor.whiteColor()
        print("ended recording")
        
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
        let url = getAudioURL()
        
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
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let current = newLocation
        let speed = current.speed*2.23694
        let speedMph = Int(round(speed))
        
        if speed <= 0 {
            mphLabel.text = "0"
        } else {
            mphLabel.text = String(speedMph)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM.dd.yyyy-hh:mm:ss"
        let todayString = formatter.stringFromDate(NSDate())

        let fullLog = "\(todayString) | \(speedMph) mph"
        logSpeed(fullLog)
    }
    
    func createLog(){
        let file = "log.txt"
        let text = "MPH LOG"
        
        let path = getFileURL(file)
            
        do {
            try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
        } catch {"ERROR: creating log"}
    }
    
    func logSpeed(logString: String){
        do {
            let url = getFileURL("log.txt")
            try logString.appendLineToURL(url)
        } catch {
            print("ERROR: could not write to log file")
        }
    }
    
    // MARK: - CoreLocation Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        if status == .AuthorizedWhenInUse || status == .Restricted || status == .Denied {
            backgroundAlert()
        } else if status == .AuthorizedAlways {
            setupLocationManager()
            setupSession()
        }

    }
    
    // Background Location Alert
    
    func backgroundAlert(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "In order to track and log your speed please open this app's settings and set location access to 'Always'.",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // File Helpers
    
    func getCacheDirectory() -> AnyObject {
        
        let paths = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)
        return paths[0]
    }
    
    func getAudioURL() -> NSURL {
        
        let path = getCacheDirectory().stringByAppendingPathComponent(fileName)
        let filePath = NSURL(fileURLWithPath: path)
        return filePath
    }
    
    func getFileURL(file: String) -> NSURL {
        let path = getCacheDirectory().stringByAppendingPathComponent(file)
        let filePath = NSURL(fileURLWithPath: path)
        return filePath
    }

    
}//class


extension String {
    func appendLineToURL(fileURL: NSURL) throws {
        try self.stringByAppendingString("\n").appendToURL(fileURL)
    }
    
    func appendToURL(fileURL: NSURL) throws {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        try data.appendToURL(fileURL)
    }
}

extension NSData {
    func appendToURL(fileURL: NSURL) throws {
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(self)
        }
        else {
            try writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}

