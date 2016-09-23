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
        if let recording = UserDefaults.standard.value(forKey: "redText") as? Bool{
            return recording
        } else {
            return true
        }
    }
    
    var shake: Bool {
        if let shake = UserDefaults.standard.value(forKey: "shake") as? Bool {
            return shake
        } else {
            return false
        }
    }
    
    var miles: Bool{
        if let miles = UserDefaults.standard.value(forKey: "miles") as? Bool {
            return miles
        } else {
            return true
        }
    }
    
    var dashMode: Bool {
        if let dash = UserDefaults.standard.value(forKey: "dashMode") as? Bool {
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
    
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        setupButtons()
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
//        if audioRecorder == nil {
//            startRecording()
//        }
//        else {
//            finishRecording(success: true)
//        }
    }
    
    @IBAction func playButtonTapped(_ sender: AnyObject) {
        //playRecording()
        do {
        let result = try String(contentsOf: getFileURL("log.txt"))
        print(result)

        } catch {
            print("Error Playing")
        }
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @IBAction func shareTapped(_ sender: AnyObject) {
        shareLog()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func checkFirstLaunch() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if !launchedBefore {
            let alert = UIAlertController(title: "Welcome", message: "This app logs your speed to a text file and will record audio when you tap on the screen as well. If the app is running it will log your speed to the file but will only record audio when the text is red or has a red dot by tapping on the screenn", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK!", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
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
        
        if self.shake {
            navBarOutlet.isHidden = false
        } else {
            navBarOutlet.isHidden = false
        }
        
        if self.miles {
            mphTextLabel.text = "mph"
        } else {
            mphTextLabel.text = "km/h"
        }
        
        if self.dashMode {
            self.view.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    // FUNCTIONS: - Audio Recording
    
    func setupSession(){
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                DispatchQueue.main.async {
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
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioUrl, settings: smallSettings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            if redText {
                speedLabel.textColor = UIColor.red
                mphTextLabel.textColor = UIColor.red
            } else {
                redDotOutlet.isHidden = false
            }
            
            buttonLabel.setTitle("STOP", for: UIControlState())
            print("...recording...")
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if redText {
            speedLabel.textColor = UIColor.white
            mphTextLabel.textColor = UIColor.white
        } else {
            redDotOutlet.isHidden = true
        }
        print("ended recording")
        
        if success {
            //buttonLabel.setTitle("RE-RECORD", forState: .Normal)
            
            let alert = UIAlertController(title: "Succesfully Recorded!", message: "Every new audio recording overwrites the last, to ensure the recording you want is not overwritten we recommend sending a copy now, would you like to send yourself a copy?", preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.shareLog()
            }
            let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(noButton)
            alert.addAction(yesButton)
            present(alert, animated: true, completion: nil)
            
        } else {
            //buttonLabel.setTitle("RECORD", forState: .Normal)
            
            let alert = UIAlertController(title: "Recording Failed", message: "There was a problem saving the recording, it could be a space issue", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func playRecording(){
        let url = getAudioURL()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: ".m4a")
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 5.0
            audioPlayer.play()
            
        } catch {
            ////finishRecording(success: false)
            print("Cant find file")
        }
    }
    
    
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
        
        logSpeed(fullLog)
    }
    
    func createLog(){
        
        let file = "log.txt"
        let text = "Speed LOG"
        
        let path = getFileURL(file)
            
        do {
            try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        } catch {"ERROR: creating log"}
    }
    
    func logSpeed(_ logString: String){
        do {
            let url = getFileURL("log.txt")
            let stringSpace = logString + "\n"
            //let data = stringSpace.data(using: String.Encoding.utf8)!
            try stringSpace.appendToURL(url)
        } catch {
            print("ERROR: could not write to log file")
        }
    }
    

    func shareLog(){
        let log = getFileURL("log.txt")
        let recording = getFileURL("recording.m4a")
        let objectsToShare = [log,recording]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSettings"{
            let vc = segue.destination as! SettingsTableViewController
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }
    }
    
    // MARK: - PopOver Delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setupButtons()
    }
    
    // MARK: - CoreLocation Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        print("CHANGED")
        if status == .restricted || status == .denied {
            backgroundAlert()
            print("location is Resricted or Denied")
        } else if status == .authorizedAlways {
            setupLocationManager()
            setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .authorizedWhenInUse {
            onlyOpenAlert()
            setupLocationManager()
            setupSession()
            setupButtons()
            print("ALWAYS")
        } else if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    // Background Location Alert
    
    func backgroundAlert(){
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order to track and log your speed while this app is open and continue logging in the background please open this app's location settings and set location access to 'Always'.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
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
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // File Helpers
    
    func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory,  FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    func getAudioURL() -> URL {
        
        let path = getCacheDirectory()
        let pathUrl = URL(fileURLWithPath: path)
        let filePath = pathUrl.appendingPathComponent(recordingFileName)
        return filePath
    }
    
    func getFileURL(_ file: String) -> URL {
        
        let path = getCacheDirectory()
        let pathUrl = URL(fileURLWithPath: path)
        let filePath = pathUrl.appendingPathComponent(file)
        return filePath
    }
    
    func checkFile(_ filename: String){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(filename).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("log available")
        } else {
            print("no log file")
            createLog()
        }
    }
    
    // Shake
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if(event!.subtype == UIEventSubtype.motionShake) {
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
