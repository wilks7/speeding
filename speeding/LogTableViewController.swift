//
//  LogTableViewController.swift
//  speeding
//
//  Created by hackintosh on 4/7/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import UIKit

class LogTableViewController: UITableViewController {

    
    @IBAction func shareTapped(_ sender: Any) {
    }
    
    @IBAction func doneTapped(_ sender: Any) {
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        if segmentOutlet.selectedSegmentIndex == 0 {
            dataSource = speedList
        } else if segmentOutlet.selectedSegmentIndex == 1 {
            dataSource = audioList
        }
        tableView.reloadData()

    }

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    
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

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if dataSource.count <= 0 {
            return 1
        } else {
            return dataSource.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logIdentifier", for: indexPath)

        if dataSource.count <= 0 {
            cell.textLabel?.text = "There are no logs"
        } else {
            let pathUrl = dataSource[indexPath.row]
            let fileName = pathUrl.lastPathComponent
            cell.textLabel?.text = fileName
        }

        return cell
    }
 
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
