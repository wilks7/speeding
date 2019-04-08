//
//  LogViewController.swift
//  speeding
//
//  Created by Michael Wilkowski on 4/8/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import UIKit
import AVFoundation

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

    
    var isPlaying: Bool = false
    
    @IBAction func shareTapped(_ sender: Any) {
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        if segmentOutlet.selectedSegmentIndex == 0 {
            playerView.isHidden = true
        } else if segmentOutlet.selectedSegmentIndex == 1 {
            dataSource = audioList
            setupAudioPlayer(url: dataSource[0])
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        } else if segmentOutlet.selectedSegmentIndex == 2 {
            dataSource = videoList
            playerView.isHidden = true
        }
        tableView.reloadData()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        audioPlayer.stop()
        audioPlayer.delegate = self
        audioPlayer.currentTime = TimeInterval(sliderOutlet.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        if audioPlayer.isPlaying {
            playButton.setTitle("Pause", for: .normal)
        } else {
            playButton.setTitle("Play", for: .normal)
        }
        
    }
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playTapped(_ sender: Any) {
        
        if audioPlayer.isPlaying {
            playButton.setTitle("Play", for: .normal)
            audioPlayer.pause()
        } else {
            playButton.setTitle("Pause", for: .normal)
            audioPlayer.play()
        }
        
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var sliderOutlet: UISlider!
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var audioPlayer: AVAudioPlayer!
    
    var dataSource:[URL] = []
    
    var audioList:[URL] = []
    var speedList:[String] = []
    var videoList:[URL] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        if segmentOutlet.selectedSegmentIndex == 0 {
            playerView.isHidden = true
            speedList = FileController.speedLogs
        } else if segmentOutlet.selectedSegmentIndex == 1 {
            dataSource = audioList
            setupAudioPlayer(url: dataSource[0])
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        } else if segmentOutlet.selectedSegmentIndex == 2 {
            dataSource = videoList
            playerView.isHidden = true
        }
        tableView.reloadData()
    }
    
    func loadData(){
        
        let urls = FileController.getAllDocuments()
        if urls.count > 0 {
            for url in urls {
                let fileName = url.lastPathComponent
                let ext = String(fileName.suffix(4))
                if ext == ".m4a" {
                    audioList.append(url)
                } else if ext == ".txt" {
                    dataSource.append(url)
                }
            }
        }
    }
    
    
    func setupAudioPlayer(url: URL){
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
            setSliderValue()
        } catch {
            print(error)
        }
    }
    
    
    func setSliderValue(){
        sliderOutlet.maximumValue = Float(audioPlayer.duration)
    }
    
    @objc func updateSlider(){
        let duration = audioPlayer.duration
        let currentTime = audioPlayer.currentTime
        let label: TimeInterval = currentTime - duration
        sliderOutlet.value = Float(audioPlayer.currentTime)

        timeStamp.text = label.format(using: [.minute, .second])
    }
    
    // MARK: - Audio Delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play", for: .normal)
    }
    
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if dataSource.count <= 0 {
            return 1
        } else {
            return dataSource.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logIdentifier", for: indexPath)
        
        if dataSource.count <= 0 {
            cell.textLabel?.text = "There are no logs"
        } else {
            if segmentOutlet.selectedSegmentIndex == 0 {
                let log = speedList[indexPath.row]
                cell.textLabel?.text = log
                cell.textLabel?.textColor = .white
            } else if segmentOutlet.selectedSegmentIndex == 1 {
                let pathUrl = dataSource[indexPath.row]
                let fileName = pathUrl.lastPathComponent
                cell.textLabel?.text = fileName
                cell.textLabel?.textColor = .white
            } else if segmentOutlet.selectedSegmentIndex == 2 {
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = dataSource[indexPath.row]
        if segmentOutlet.selectedSegmentIndex == 1 {
            setupAudioPlayer(url: log)
            playerView.isHidden = false
            audioPlayer.play()
            if audioPlayer.isPlaying {
                playButton.setTitle("Pause", for: .normal)
            } else {
                playButton.setTitle("Play", for: .normal)
            }
        }
    }

}

extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }}
