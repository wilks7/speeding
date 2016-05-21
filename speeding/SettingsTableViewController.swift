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
    
    @IBAction func shakeSwitchChanged(sender: AnyObject) {
        if shakeSwitchOutlet.on {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shake")
            print("switched on")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shake")
            print("switched off")
        }
    }
    
    @IBAction func dashSwitchChanged(sender: AnyObject) {
        if dashSwitchOutlet.on {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "dashMode")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "dashMode")
        }
    }
    
    
    @IBAction func exitButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func locationButtonTapped(sender: AnyObject) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    @IBAction func redSegmentChanged(sender: AnyObject) {
        if redSegmentOutlet.selectedSegmentIndex == 0 {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "redText")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "redText")
        }
    }
    
    @IBAction func distanceSegmentChanged(sender: AnyObject) {
        if distanceSegmentOutlet.selectedSegmentIndex == 0 {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "miles")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "miles")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.borderWidth = 2.5
        self.view.layer.cornerRadius = 5
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        
        locationButtonOutlet.layer.borderWidth = 1
        locationButtonOutlet.layer.cornerRadius = 5
        locationButtonOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
    
    func setupButtons(){
        
        if let shake = NSUserDefaults.standardUserDefaults().valueForKey("shake") as? Bool{
            if shake {
                shakeSwitchOutlet.setOn(true, animated: false)
            } else {
                shakeSwitchOutlet.setOn(false, animated: false)
            }
        }
        if let recording = NSUserDefaults.standardUserDefaults().valueForKey("redText") as? Bool{
            if recording {
                redSegmentOutlet.selectedSegmentIndex = 0
            } else {
                redSegmentOutlet.selectedSegmentIndex = 1
            }
        }
        
        if let distance = NSUserDefaults.standardUserDefaults().valueForKey("miles") as? Bool {
            if distance {
                distanceSegmentOutlet.selectedSegmentIndex = 0
            } else {
                distanceSegmentOutlet.selectedSegmentIndex = 1
            }
        }
        
        if let dash = NSUserDefaults.standardUserDefaults().valueForKey("dashMode") as? Bool {
            if dash {
                dashSwitchOutlet.setOn(true, animated: false)
            } else {
                dashSwitchOutlet.setOn(false, animated: false)
            }
        }
    }
}
