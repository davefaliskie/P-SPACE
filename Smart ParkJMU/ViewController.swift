//
//  ViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 11/9/15.
//  Copyright © 2015 Riley Sung. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    // Lot instance variable
    var lots = []
    var spaces = []
    
    // Lot Labels
    @IBOutlet weak var lotsTableView: UITableView!
    @IBOutlet weak var didPressButtonLoginOrGoToAdminPage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Function run when view is loading
        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function run when view is loading
    func setup() {
        
        checkLoginStatus()
        
        // Sets lots array to lot names and ids from GET request
        lots = ViewController.getLotNames()
        
        
        
    }
        
    // GET Api call to get Lot Names and ID to display tabularly and select by Lot Id
    class func getLotNames() -> NSArray {
        
        var lotData = []
        
        let nsUrl = NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/getLotNames.php")
        
        let semaphore = dispatch_semaphore_create(0)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!){
            (data, response, error) in
            
            do {
                
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                lotData = jsonResult as! NSArray
//                print("data: ", lotData)
                
            } catch {
                
                print ("JSON serialization failed")
            }
            
            dispatch_semaphore_signal(semaphore)
            
        }
        
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return lotData
    }
    
    
    // Table configuration to display the number of rows for each lot returned from getLotNames function
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return lots.count
    
    }
    
    // Table configuration to set table row title to be lot name
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let lotName = (lots[indexPath.row]["Lot_Name"]) as! String
        
        cell.textLabel?.text = lotName
        cell.textLabel?.sizeToFit()
        cell.textLabel?.font = UIFont.systemFontOfSize(38)          // font size
        cell.textLabel?.textAlignment = NSTextAlignment.Center      // align text in the center
        cell.backgroundColor = UIColor.clearColor()                 // cell background clear
        
        return cell
    }

    // IBAction + segue to return to this view
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
        // Check if user is logged in to determine whether to have login or admin lots button enabled
        checkLoginStatus()
        
    }
    
    // If user is logged in, button (login or admin lots) will bring user to admin lots view instead of login view
    @IBAction func didPressLoginOrAdminPage(sender: AnyObject) {
        
        if globalVar.loggedIn == false {
            
            self.performSegueWithIdentifier("seguetoAdminLoginViewController", sender: nil)
            
        } else {
            
            self.performSegueWithIdentifier("segueToAdminLotsViewController", sender: nil)
            
        }
        
    }
    
    // If the next view is Single Lot View, this passes the selected lot Id to SingleLotViewController for rest of the lot's data to be loaded and displayed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToSingleLotViewController" {

            if let destination = segue.destinationViewController as? SingleLotViewController {

                if let index = lotsTableView.indexPathForSelectedRow?.row {

                    let lotPassed = lots[index] as! NSDictionary
                    destination.lotId = lotPassed["Id"]!.integerValue
                
                }
            }
        }
    }
    
    // When a lot is selected, segue to Single Lot View
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("segueToSingleLotViewController", sender: nil)
    
    }
    
    // Check if user is logged in to determine whether to have login or admin lots button enabled
    func checkLoginStatus() {
        
        if globalVar.loggedIn == true {
            
            didPressButtonLoginOrGoToAdminPage.setTitle("Admin Page", forState: .Normal)
            
        } else {
            
            didPressButtonLoginOrGoToAdminPage.setTitle("Login", forState: .Normal)
            
        }
    }
    
}

