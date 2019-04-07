//
//  SettingsTableViewController.swift
//  speeding
//
//  Created by wilksmac on 5/21/16.
//  Copyright © 2016 wilksmac. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var redSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var distanceSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var shakeSwitchOutlet: UISwitch!
    @IBOutlet weak var locationButtonOutlet: UIButton!
    @IBOutlet weak var dashSwitchOutlet: UISwitch!
    
    @IBAction func shakeSwitchChanged(_ sender: AnyObject) {
        if shakeSwitchOutlet.isOn {
            UserDefaults.standard.set(true, forKey: "shake")
            print("switched on")
        } else {
            UserDefaults.standard.set(false, forKey: "shake")
            print("switched off")
        }
    }
    
    @IBAction func dashSwitchChanged(_ sender: AnyObject) {
        if dashSwitchOutlet.isOn {
            UserDefaults.standard.set(true, forKey: "dashMode")
        } else {
            UserDefaults.standard.set(false, forKey: "dashMode")
        }
    }
    
    
    @IBAction func exitButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationButtonTapped(_ sender: AnyObject) {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func redSegmentChanged(_ sender: AnyObject) {
        if redSegmentOutlet.selectedSegmentIndex == 0 {
            UserDefaults.standard.set(true, forKey: "redText")
        } else {
            UserDefaults.standard.set(false, forKey: "redText")
        }
    }
    
    @IBAction func distanceSegmentChanged(_ sender: AnyObject) {
        if distanceSegmentOutlet.selectedSegmentIndex == 0 {
            UserDefaults.standard.set(true, forKey: "miles")
        } else {
            UserDefaults.standard.set(false, forKey: "miles")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
    
    func buttonLayout(){
        self.view.layer.borderWidth = 2.5
        self.view.layer.cornerRadius = 5
        self.view.layer.borderColor = UIColor.white.cgColor
        
        locationButtonOutlet.layer.borderWidth = 1
        locationButtonOutlet.layer.cornerRadius = 5
        locationButtonOutlet.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupButtons(){
        
        if let shake = UserDefaults.standard.value(forKey: "shake") as? Bool{
            if shake {
                shakeSwitchOutlet.setOn(true, animated: false)
            } else {
                shakeSwitchOutlet.setOn(false, animated: false)
            }
        }
        if let recording = UserDefaults.standard.value(forKey: "redText") as? Bool{
            if recording {
                redSegmentOutlet.selectedSegmentIndex = 0
            } else {
                redSegmentOutlet.selectedSegmentIndex = 1
            }
        }
        
        if let distance = UserDefaults.standard.value(forKey: "miles") as? Bool {
            if distance {
                distanceSegmentOutlet.selectedSegmentIndex = 0
            } else {
                distanceSegmentOutlet.selectedSegmentIndex = 1
            }
        }
        
        if let dash = UserDefaults.standard.value(forKey: "dashMode") as? Bool {
            if dash {
                dashSwitchOutlet.setOn(true, animated: false)
            } else {
                dashSwitchOutlet.setOn(false, animated: false)
            }
        }
    }
}
