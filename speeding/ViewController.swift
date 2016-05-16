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

class ViewController: UIViewController, AVAudioRecorderDelegate, CLLocationManagerDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isRecording = false
    
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        if audioRecorder == nil {
            mphLabel.textColor = UIColor.redColor()
            startRecording()
        }
        else {
            mphLabel.textColor = UIColor.whiteColor()
            finishRecording(success: true)
        }
    }
    
    var locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            print("hi")
        case .NotDetermined:
            locationManger.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        print("Got persmission")
                    } else {
                        print("Didnt get permission")
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
//    func recordTapped() {
//        if audioRecorder == nil {
//            startRecording()
//        } else {
//            finishRecording(success: true)
//        }
//    }
    
    func startRecording() {
        
        var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        var str =  documents.stringByAppendingPathComponent("recording.m4a")
        var audioUrl = NSURL.fileURLWithPath(str as String)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            buttonLabel.setTitle("STOP", forState: .Normal)
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            buttonLabel.setTitle("RE-RECORD", forState: .Normal)
        } else {
            buttonLabel.setTitle("RECORD", forState: .Normal)
            // recording failed :(
        }
    }
    
    func setupLocationManager(){
        locationManger.delegate = self
        locationManger.distanceFilter = kCLDistanceFilterNone
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        //locationManger.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location found")
        
        if let foundLocation = locations.first{
            print(foundLocation.coordinate)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        print("Cant Get Current Location")
    }
    

}

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


