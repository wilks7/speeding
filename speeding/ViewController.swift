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

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    //static let sharedInstance = ViewController()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var locationManager = CLLocationManager()

    let recordingFileName = "recording.m4a"
    
    var redText: Bool {
        if let recording = NSUserDefaults.standardUserDefaults().valueForKey("redText") as? Bool{
            return recording
        } else {
            return true
        }
    }
    
    var shake: Bool {
        if let shake = NSUserDefaults.standardUserDefaults().valueForKey("shake") as? Bool {
            return shake
        } else {
            return false
        }
    }
    
    var miles: Bool{
        if let miles = NSUserDefaults.standardUserDefaults().valueForKey("miles") as? Bool {
            return miles
        } else {
            return true
        }
    }
    
    var dashMode: Bool {
        if let dash = NSUserDefaults.standardUserDefaults().valueForKey("dashMode") as? Bool {
            return dash
        } else {
            return false
        }
    }
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var mphTextLabel: UILabel!
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var playButtonLabel: UIButton!
    
    @IBOutlet weak var navBarOutlet: UINavigationBar!
    @IBOutlet weak var shareButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var settingsButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var redDotOutlet: UIView!
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
        setupButtons()
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
//        if audioRecorder == nil {
//            startRecording()
//        }
//        else {
//            finishRecording(success: true)
//        }
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        //playRecording()
        do {
        let result = try String(contentsOfURL: getFileURL("log.txt"))
        print(result)

        } catch {
            print("Error Playing")
        }
    }
    
    @IBAction func settingsTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettings", sender: self)
    }
    
    @IBAction func shareTapped(sender: AnyObject) {
        shareLog()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if audioRecorder == nil {
            setupSession()
            startRecording()
        }
        else {
            finishRecording(success: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFile("log.txt")
        setupButtons()
        setupLocationManager()
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupButtons(){
        buttonLabel.hidden = true
        playButtonLabel.hidden = true
        redDotOutlet.hidden = true
        speedLabel.font = UIFont(name: "DBLCDTempBlack", size: 150.0)
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways && CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            speedLabel.text = "--"
            mphTextLabel.hidden = true
        } else {
            speedLabel.text = "0"
            mphTextLabel.hidden = false
        }
        
        if self.shake {
            navBarOutlet.hidden = false
        } else {
            navBarOutlet.hidden = false
        }
        
        if self.miles {
            mphTextLabel.text = "mph"
        } else {
            mphTextLabel.text = "km/h"
        }
        
        if self.dashMode {
            self.view.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            self.view.transform = CGAffineTransformMakeScale(1, 1)
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
        
//        let maxSettings = [//filename should be .caf
//            AVFormatIDKey: Int(kAudioFormatAppleLossless),
//            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
//            AVEncoderBitRateKey : 320000,
//            AVNumberOfChannelsKey: 2 as NSNumber,
//            AVSampleRateKey : 44100.0
//        ]
        
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
            
            if redText {
                speedLabel.textColor = UIColor.redColor()
                mphTextLabel.textColor = UIColor.redColor()
            } else {
                redDotOutlet.hidden = false
            }
            
            buttonLabel.setTitle("STOP", forState: .Normal)
            print("...recording...")
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if redText {
            speedLabel.textColor = UIColor.whiteColor()
            mphTextLabel.textColor = UIColor.whiteColor()
        } else {
            redDotOutlet.hidden = true
        }
        print("ended recording")
        
        if success {
            //buttonLabel.setTitle("RE-RECORD", forState: .Normal)
            
            let alert = UIAlertController(title: "Succesfully Recorded!", message: "Every new audio recording overwrites the last, to ensure the recording you want is not overwritten we recommend sending a copy now, would you like to send yourself a copy?", preferredStyle: .Alert)
            let yesButton = UIAlertAction(title: "Yes", style: .Default) { (action) in
                self.shareLog()
            }
            let noButton = UIAlertAction(title: "No", style: .Default, handler: nil)
            alert.addAction(noButton)
            alert.addAction(yesButton)
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            //buttonLabel.setTitle("RECORD", forState: .Normal)
            
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
        let speed = newLocation.speed
        let speedKph = Int(round(speed*3.6))
        let speedMph = Int(round(speed*2.23694))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM.dd.yyyy-hh:mm:ss"
        let todayString = formatter.stringFromDate(NSDate())
        
        var fullLog = ""
        
        if speed <= 0 {
            speedLabel.text = "0"
        } else {
            if self.miles {
                mphTextLabel.text = "mph"
                speedLabel.text = String(speedMph)
                fullLog = "\(todayString) | \(speedMph) mph"
            } else {
                mphTextLabel.text = "km/h"
                speedLabel.text = String(speedKph)
                fullLog = "\(todayString) | \(speedKph) kph"
            }
        }

        logSpeed(fullLog)
    }
    
    func createLog(){
        
        let file = "log.txt"
        let text = "Speed LOG"
        
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
    
    func shareLog(){
        let log = getFileURL("log.txt")
        let recording = getFileURL("recording.m4a")
        let objectsToShare = [log,recording]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showSettings"{
            let vc = segue.destinationViewController as! SettingsTableViewController
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }
    }
    
    // MARK: - PopOver Delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        setupButtons()
    }
    
    // MARK: - CoreLocation Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        print("CHANGED")
        if status == .Restricted || status == .Denied {
            backgroundAlert()
            print("location is Resricted or Denied")
        } else if status == .AuthorizedAlways {
            setupLocationManager()
            setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .AuthorizedWhenInUse {
            onlyOpenAlert()
            setupLocationManager()
            setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    // Background Location Alert
    
    func backgroundAlert(){
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to track and log your speed while this app is open and continue logging in the background please open this app's location settings and set location access to 'Always'.",
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
    
    func onlyOpenAlert(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "If you would like the app to continue tracking your speed while the app is put in the background please open this app's location settings and set location access to 'Always'. .",
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
        
        let path = getCacheDirectory().stringByAppendingPathComponent(recordingFileName)
        let filePath = NSURL(fileURLWithPath: path)
        return filePath
    }
    
    func getFileURL(file: String) -> NSURL {
        
        let path = getCacheDirectory().stringByAppendingPathComponent(file)
        let filePath = NSURL(fileURLWithPath: path)
        return filePath
    }
    
    func checkFile(filename: String){
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.URLByAppendingPathComponent(filename).path!
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            print("log available")
        } else {
            print("no log file")
            createLog()
        }
    }
    
    // Shake
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if(event!.subtype == UIEventSubtype.MotionShake) {
            if self.shake {
                if navBarOutlet.hidden {
                    navBarOutlet.hidden = false
                } else {
                    navBarOutlet.hidden = true
                }
            } else {
                navBarOutlet.hidden = false
            }
            print("shake shake shake")
        }
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