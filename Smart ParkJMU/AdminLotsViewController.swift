//
//  AdminLotsViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 1/24/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class AdminLotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Lot instance variables
    var lots = []
    var lotName = String()
    var lotId = Int()
    
    // Table view
    @IBOutlet weak var adminLotsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        lots = ViewController.getLotNames()
        
        // Reloads table view when view is being loaded from other views
        adminLotsTableView.reloadData()
    }
    
    // Function run when view is loading
    func setup() {
        
        // Sets lots array to the returned array of lot names and ids
        lots = ViewController.getLotNames()
    }
    
    // Function run when logout button pressed
    @IBAction func didPressLogout(sender: AnyObject) {
        
        // Sets global logged in variable to false
        globalVar.loggedIn = false
        
    }
    
    // Segue to unwind back to this view
    @IBAction func unwindToAdminLotsViewController(segue: UIStoryboardSegue) {
    }
    
    // Table view configuration: Sets number of rows in table to be the number of lots in lots array
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return lots.count
        
    }
    
    // Table view configuration: Sets each row title to lot names and other configurations
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        let lotName = (lots[indexPath.row]["Lot_Name"]) as! String
        
        cell.textLabel!.text = lotName
        
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel?.sizeToFit()
        cell.textLabel?.font = UIFont.systemFontOfSize(38)          // font size
        cell.textLabel?.textAlignment = NSTextAlignment.Center      // align text in the center
        cell.backgroundColor = UIColor.clearColor()                 // cell background clear
       
        return cell
    }
    
    // Table view: When a row/lot is selected, segue to manage lot
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("segueToManageLotFromTable", sender: nil)

        
    }
    
    // When segueing to create or save lot view, if lot was selected: load the lot in the next view, otherwise the next view will be blank for lot creation. This is flagged by managementType variable
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToManageLotFromTable" {
            
            // If lot selected, pass lot id, name, and managementType to manage
            if let destination = segue.destinationViewController as? CreateLotViewController {
                
                if let index = adminLotsTableView.indexPathForSelectedRow?.row {
                    
                    destination.lotId = lots[index]["Id"]!!.integerValue
                    destination.lotName = lots[index]["Lot_Name"] as! String
                    destination.managementType = "Manage"
                    
                }
            }
            
        } else {
            
            // If creating a lot, set managementType variable to create
            if let destination = segue.destinationViewController as? CreateLotViewController {
        
                    destination.managementType = "Create"
                    
            }
            
        }
        
        // If next view type is homescreen (ViewController), reload the table in that view
        if let destination = segue.destinationViewController as? ViewController {
            
            destination.lots = ViewController.getLotNames()
            
            destination.lotsTableView.reloadData()
            
            
        }
    }

}
