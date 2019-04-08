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
        
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var locationManager = CLLocationManager()

    var fileName = "placeholder.m4a"
    
    var recording: Bool = false
    var redText: Bool = false
    var shake: Bool = false
    var miles: Bool = true
    var dashMode: Bool = false
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var mphTextLabel: UILabel!
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var playButtonLabel: UIButton!
    
    @IBOutlet weak var navBarOutlet: UINavigationBar!
    @IBOutlet weak var shareButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var settingsButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var redDotOutlet: UIView!
    
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        setupButtons()
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {

    }
    
    @IBAction func playButtonTapped(_ sender: AnyObject) {
        setupPlayer()
        audioPlayer.play()
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @IBAction func shareTapped(_ sender: AnyObject) {
        //shareLog()
    }
    
    @objc func doubleTapped() {
        
    }
    
    @objc func tapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy-hh:mm:ss"
        fileName = formatter.string(from: Date()) + ".m4a"
        
        let audioFilename = FileController.getDocumentsDirectory().appendingPathComponent(fileName)
        
        let maxSettings = [//filename should be .caf
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVSampleRateKey : 44100.0
            ] as [String:Any]
        
        let smallSettings = [//filename should be .m4a
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: maxSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
        
        if !recording {
            audioRecorder.record()
            
            if redText {
                speedLabel.textColor = UIColor.red
                mphTextLabel.textColor = UIColor.red
            } else {
                redDotOutlet.isHidden = false
            }
            print("...recording...")
            
            self.recording = true
        }
        else {
            audioRecorder.stop()
            self.recording = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FileController.checkFile("log.txt")
        setupButtons()
        setupLocationManager()
        //setupRecorder()
        UIApplication.shared.isIdleTimerDisabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupButtons(){
        buttonLabel.isHidden = true
        playButtonLabel.isHidden = true
        redDotOutlet.isHidden = true
        speedLabel.font = UIFont(name: "DBLCDTempBlack", size: 150.0)
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways && CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            speedLabel.text = "--"
            mphTextLabel.isHidden = true
        } else {
            speedLabel.text = "0"
            mphTextLabel.isHidden = false
        }
        
        // Check UserSettings and then Set the UI
        if let recording = UserDefaults.standard.value(forKey: "redText") as? Bool{
            self.redText = recording
        } else { self.redText = true }
        
        if let shake = UserDefaults.standard.value(forKey: "shake") as? Bool {
            self.shake = shake
        } else { self.shake = false }
        if self.shake { navBarOutlet.isHidden = false }
            else { navBarOutlet.isHidden = false }
        
        if let miles = UserDefaults.standard.value(forKey: "miles") as? Bool {
            self.miles = miles
        } else { self.miles = true }
        if self.miles { mphTextLabel.text = "mph"}
            else { mphTextLabel.text = "km/h" }
        
        if let dash = UserDefaults.standard.value(forKey: "dashMode") as? Bool {
            self.dashMode = dash
        } else { self.dashMode = false }
        if self.dashMode {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func setupPlayer(){
        
        let audioFilename = FileController.getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        } catch {
            print(error)
        }
        
    }
    
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM.dd.yyyy-hh:mm:ss"
//        fileName = formatter.string(from: Date()) + ".m4a"
//
//        let audioFilename = FileController.getDocumentsDirectory().appendingPathComponent(fileName)
//
//        let maxSettings = [//filename should be .caf
//            AVFormatIDKey: kAudioFormatAppleLossless,
//            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
//            AVEncoderBitRateKey : 320000,
//            AVNumberOfChannelsKey: 2 as NSNumber,
//            AVSampleRateKey : 44100.0
//            ] as [String:Any]
//
//        let smallSettings = [//filename should be .m4a
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000.0,
//            AVNumberOfChannelsKey: 1 as NSNumber,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ] as [String : Any]
//
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: maxSettings)
//            audioRecorder.delegate = self
//            audioRecorder.prepareToRecord()
//        } catch {
//            print(error)
//        }
//
//        if !recording {
//            audioRecorder.record()
//
//            if redText {
//                speedLabel.textColor = UIColor.red
//                mphTextLabel.textColor = UIColor.red
//            } else {
//                redDotOutlet.isHidden = false
//            }
//            print("...recording...")
//
//            self.recording = true
//        }
//        else {
//            audioRecorder.stop()
//            self.recording = false
//        }
//    }


    func shareLog(){
        let log = FileController.getFileURL("log.txt")
        let recording = FileController.getFileURL("recording.m4a")
        let objectsToShare = [log,recording]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }


    // MARK: - Audio Delegate

    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if redText {
            speedLabel.textColor = UIColor.white
            mphTextLabel.textColor = UIColor.white
        } else {
            redDotOutlet.isHidden = true
        }
        print("ended recording")
        
    
        let alert = UIAlertController(title: "Succesfully Recorded!", message: "Tap the share button in the top left to send yourself an email or record onto the blockchain", preferredStyle: .alert)
//        let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
//            self.shareLog()
//        }
        let noButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(noButton)
        //alert.addAction(yesButton)
        present(alert, animated: true, completion: nil)
            
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished audio")
    }
    
    
    
    // MARK: - PopOver Delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setupButtons()
    }
    
    
    
    // MARK: - CoreLocation Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return;}
        
        let speed = location.speed
        let speedKph = Int(round(speed*3.6))
        let speedMph = Int(round(speed*2.23694))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy-hh:mm:ss"
        let todayString = formatter.string(from: Date())
        
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
        
        FileController.logSpeed(fullLog)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        print("CHANGED")
        if status == .restricted || status == .denied {
            backgroundAlert()
            print("location is Resricted or Denied")
        } else if status == .authorizedAlways {
            setupLocationManager()
            //setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .authorizedWhenInUse {
            onlyOpenAlert()
            setupLocationManager()
            //setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    // MARKE: - Background Location Alert
    
    func backgroundAlert(){
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to log your speed the app needs permission to access location data, please open this app's location settings and set location access.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onlyOpenAlert(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "If you would like the app to continue tracking your speed while the app is put in the background please open this app's location settings and set location access to 'Always'. .",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Shake Functionality
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if(event!.subtype == UIEvent.EventSubtype.motionShake) {
            if self.shake {
                if navBarOutlet.isHidden {
                    navBarOutlet.isHidden = false
                } else {
                    navBarOutlet.isHidden = true
                }
            } else {
                navBarOutlet.isHidden = false
            }
            print("shake shake shake")
        }
    }
    
    func checkFirstLaunch() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if !launchedBefore {
            let alert = UIAlertController(title: "Welcome", message: "This app logs your speed to a text file and will record audio ONLY when you tap on the screen as well. If the app is running it will always log your speed to the file but will ONLY record audio when the Number is Red or has a Red Dot by tapping on the screen", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK!", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSettings"{
            let vc = segue.destination as! SettingsTableViewController
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }
    }
    
}//class


extension String {
    
    func appendToURL(_ fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL)
    }
}


extension Data {
    func appendToURL(_ fileURL: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
