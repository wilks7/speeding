//
//  LogViewController.swift
//  speeding
//
//  Created by Michael Wilkowski on 4/8/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import UIKit
import AVFoundation

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBAction func shareTapped(_ sender: Any) {
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        if segmentOutlet.selectedSegmentIndex == 0 {
            dataSource = speedList
        } else if segmentOutlet.selectedSegmentIndex == 1 {
            dataSource = audioList
            setupAudioPlayer(url: dataSource[0])
            setSliderValue()
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)

        }
        tableView.reloadData()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(sliderOutlet.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
    }
    
    
    @IBOutlet weak var sliderOutlet: UISlider!
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var audioPlayer: AVAudioPlayer!
    
    var dataSource:[URL] = []
    
    var audioList:[URL] = []
    var speedList:[URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        if segmentOutlet.selectedSegmentIndex == 0 {
            dataSource = speedList
        } else if segmentOutlet.selectedSegmentIndex == 1 {
            dataSource = audioList
            setupAudioPlayer(url: dataSource[0])
            _ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
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
                    speedList.append(url)
                }
            }
        }
    }
    
    
    func setupAudioPlayer(url: URL){
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        } catch {
            print(error)
        }
    }
    
    
    func setSliderValue(){
        sliderOutlet.maximumValue = Float(audioPlayer.duration)
    }
    
    @objc func updateSlider(){
        
        sliderOutlet.value = Float(audioPlayer.currentTime)
        print(sliderOutlet.value)
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
            let pathUrl = dataSource[indexPath.row]
            let fileName = pathUrl.lastPathComponent
            cell.textLabel?.text = fileName
            cell.textLabel?.textColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = dataSource[indexPath.row]
        if segmentOutlet.selectedSegmentIndex == 1 {
            setupAudioPlayer(url: log)
            audioPlayer.play()
        }
    }

}
