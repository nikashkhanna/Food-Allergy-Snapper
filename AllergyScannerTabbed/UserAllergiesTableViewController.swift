
//
//  UserAllergiesTableViewController.swift
//  AllergyScanner
//
//  Created by nikash khanna on 8/9/15.
//  Copyright (c) 2015 nikash khanna. All rights reserved.
//

import UIKit

var userAllergies = [""];

var hidden = [""];
var  alternateAllergies = ["": hidden];

class UserAllergiesTableViewController: UITableViewController {
    
    var edittingAllergens = false;

    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBAction func editAllergens(_ sender: AnyObject) {
        if (edittingAllergens) {
            editButton.title = "Edit";
            tableView.setEditing(false, animated: true);
            edittingAllergens = false;
        }
        else if (!edittingAllergens) {
            editButton.title = "Done";
            tableView.setEditing(true, animated: true);
            edittingAllergens = true;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bridgeForKochava.swiftTrackEvent("SessionBegin", "Started App")

        hidden.removeAll(keepingCapacity: true)
        alternateAllergies.removeAll(keepingCapacity: true)
        var startAdding = false
        var endAdding = false
        var tempKey = ""
        userAllergies.removeAll(keepingCapacity: false);
        if(UserDefaults.standard.object(forKey: "allergies") != nil ){
            userAllergies = UserDefaults.standard.object(forKey: "allergies") as! [String]
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
            
        self.tabBarController?.tabBar.barTintColor = UIColor.groupTableViewBackground
        
        
        let path = Bundle.main.path(forResource: "altAllergenNames", ofType: "txt")
        
        if let aStreamReader = StreamReader(path: path!) {
            while let line = aStreamReader.nextLine() {
                let nsLine = NSString(string: line)
                if (nsLine.substring(with: NSRange(location: 0, length: 1)) == "*") && (startAdding == false) {
                    startAdding = true;
                    tempKey = nsLine.substring(from: 1) as String;
                }
                else if(nsLine.substring(with: NSRange(location: 0, length: 1)) == "*") && (startAdding == true) {
                    alternateAllergies[tempKey] = hidden
                    tempKey = nsLine.substring(from: 1) as String
                    hidden.removeAll(keepingCapacity: false)
                }
                else if startAdding == true {
                    hidden.append(nsLine as String)
                }
            }
            // You can close the underlying file explicitly. Otherwise it will be
            // closed when the reader is deallocated.
            
            aStreamReader.close()
        }
        //println(alternateAllergies);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userAllergies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allergenCell", for: indexPath) as! AllergenCell
        
        
        cell.allergenLabel.text = userAllergies[indexPath.row]
        //cell.textLabel?.text = userAllergies[indexPath.row]
        //cell.textLabel?.textColor = UIColor.whiteColor();
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.shouldAutorotate;
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override var shouldAutorotate : Bool {
        return false
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            userAllergies.remove(at: indexPath.row);
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            UserDefaults.standard.set(userAllergies, forKey: "allergies");
            
            tableView.reloadData();
            
        }
    }
   
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
