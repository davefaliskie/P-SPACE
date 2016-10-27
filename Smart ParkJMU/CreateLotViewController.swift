//
//  CreateLotViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 1/24/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class CreateLotViewController: UIViewController, UITextFieldDelegate {
   
    // Labels
    @IBOutlet weak var createOrManageLotTitleLabel: UILabel!
    @IBOutlet weak var createOrSaveButtonLabel: UIButton!

    @IBOutlet weak var deleteButtonLabel: UIButton!
    
    @IBOutlet weak var lotNameTextField: UITextField!
    var lotName: String = ""
    @IBOutlet weak var lotLocationTextField: UITextField!
    var lotLocation: String = ""
    
    @IBOutlet weak var alertLabel: UILabel!

    // Lot Textfields
    @IBOutlet weak var generalSpotsAvailableTextField: UITextField!
    @IBOutlet weak var generalSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var handicapSpotsAvailableTextField: UITextField!
    @IBOutlet weak var handicapSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var meteredSpotsAvailableTextField: UITextField!
    @IBOutlet weak var meteredSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var motorcycleSpotsAvailableTextField: UITextField!
    @IBOutlet weak var motorcycleSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var visitorSpotsAvailableTextField: UITextField!
    @IBOutlet weak var visitorSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var totalSpotsAvailableTextField: UILabel!
    @IBOutlet weak var totalSpotsTotalTextField: UILabel!
    
    // Instance Variable for lotspots
    var lotSpots = ["genAvail": 876325, "genTotal": 876325,
        "handicapAvail": 876325, "handicapTotal": 876325,
        "meteredAvail": 876325, "meteredTotal": 876325,
        "motorcycleAvail": 876325, "motorcycleTotal": 876325,
        "visitorAvail": 876325, "visitorTotal": 876325,
        "housekeepingAvail": 876325, "housekeepingTotal": 876325,
        "serviceAvail": 876325, "serviceTotal": 876325,
        "hallDirectorAvail": 876325, "hallDirectorTotal": 876325,
        "miscAvail": 876325, "miscTotal": 876325,
        "totalAvail": 876325, "totalTotal": 876325]

    var createAttempts: Int = 0
    static var responseString: String = ""
    
     // After editing any available spot info, calculate total number of entered available spots if all lot spots are filled
    @IBAction func calculateAvailableSpots(sender: UITextField) {
        calculateAvailableSpots()
    }
    
    // After editing any capacity spot info, calculate total number of entered capacity spots if all lot spots are filled
    @IBAction func calculateTotalSpots(sender: UITextField) {
        calculateTotalSpots()
    }
    
    var lotId = Int()
    var lot = NSDictionary()
    
    var managementType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Function run when view is initially loaded
        viewSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewSetup() {
        
        // Check whether user is managing or creating a lot
        checkCreateOrManageLot()
        
        // Hides and makes alert label corner round
        alertLabel.hidden = true
        alertLabel.layer.masksToBounds = true;
        alertLabel.layer.cornerRadius = 19;
        
        // If managing a lot, get lot based on lotId, parse lot data, and calculate available and total spots if all are entered
        if managementType == "Manage" {
            lot = SingleLotViewController.getLotData(lotId)[0] as! NSDictionary
            parseLot()
            
            calculateAvailableSpots()
            calculateTotalSpots()
        }
        
        // If totalAvail = 876325 (created number for checking values), make it hidden
        if lotSpots["totalAvail"] == 876325 {
            totalSpotsAvailableTextField.hidden = true
        }
        
        // If totalSpotsTotal = 876325 (created number for checking values), make it hidden
        if lotSpots["totalTotal"] == 876325 {
            totalSpotsTotalTextField.hidden = true
        }
    }
    
    // Closes keyboard when touching background
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // If segueing to admin lots view, get all lot names and id's and reload the table in that view
        if let destination = segue.destinationViewController as? AdminLotsViewController {
            destination.lots = ViewController.getLotNames()
            destination.adminLotsTableView.reloadData()

        }
        
        // If segueing to next create or save lots view, pass lot data from current page
        if let destination = segue.destinationViewController as? CreateLotViewControllerTwo {
            destination.managementType = managementType
            destination.lotId = lotId
            destination.lotName = lotNameTextField.text!
            destination.lotLocation = lotLocationTextField.text!
            destination.lotSpots = lotSpots
            
        }
    }
    
    // Parses data to be managed easily
    func parseLot() {
        
        if let lotLoc = lot["Location"] as! String? {
            lotLocationTextField.text = lotLoc
        }
        
        if let genAvail = lot["General_Available"]!.integerValue as Int? {
            generalSpotsAvailableTextField.text = String(genAvail)
            lotSpots["genAvail"] = genAvail
        }
        if let genTotal = lot["General_Capacity"]!.integerValue as Int? {
            generalSpotsTotalTextField.text = String(genTotal)
            lotSpots["genTotal"] = genTotal
        }
        
        if let handicap = lot["Handicap_Available"]!.integerValue as Int? {
            handicapSpotsAvailableTextField.text = String(handicap)
            lotSpots["handicap"] = handicap
        }
        if let handicap = lot["Handicap_Capacity"]!.integerValue as Int? {
            handicapSpotsTotalTextField.text = String(handicap)
            lotSpots["handicap"] = handicap
        }
        
        if let meteredAvail = lot["Metered_Available"]!.integerValue as Int? {
            meteredSpotsAvailableTextField.text = String(meteredAvail)
            lotSpots["metered"] = meteredAvail
        }
        if let meteredTotal = lot["Metered_Capacity"]!.integerValue as Int? {
            meteredSpotsTotalTextField.text = String(meteredTotal)
            lotSpots["metered"] = meteredTotal
        }
        
        if let motorcycleAvail = lot["Motorcycle_Available"]!.integerValue as Int? {
            motorcycleSpotsAvailableTextField.text = String(motorcycleAvail)
            lotSpots["motorcycleAvail"] = motorcycleAvail
        }
        if let motorcycleTotal = lot["Motorcycle_Capacity"]!.integerValue as Int? {
            motorcycleSpotsTotalTextField.text = String(motorcycleTotal)
            lotSpots["motorcycleTotal"] = motorcycleTotal
        }
        
        if let visitorAvail = lot["Visitor_Available"]!.integerValue as Int? {
            visitorSpotsAvailableTextField.text = String(visitorAvail)
            lotSpots["visitorAvail"] = visitorAvail
        }
        if let visitorTotal = lot["Visitor_Capacity"]!.integerValue as Int? {
            visitorSpotsTotalTextField.text = String(visitorTotal)
            lotSpots["visitorTotal"] = visitorTotal
        }
        
        if let housekeepingAvail = lot["Housekeeping_Available"]!.integerValue as Int? {
            lotSpots["housekeepingAvail"] = housekeepingAvail
        }
        if let housekeepingTotal = lot["Housekeeping_Capacity"]!.integerValue as Int? {
            lotSpots["housekeepingTotal"] = housekeepingTotal
        }
        
        if let serviceAvail = lot["Service_Available"]!.integerValue as Int? {
            lotSpots["serviceAvail"] = serviceAvail
        }
        if let serviceTotal = lot["Service_Capacity"]!.integerValue as Int? {
            lotSpots["serviceTotal"] = serviceTotal
        }
        
        if let hallDirectorAvail = lot["Hall_Director_Available"]!.integerValue as Int? {
            lotSpots["hallDirectorAvail"] = hallDirectorAvail
        }
        if let hallDirectorTotal = lot["Hall_Director_Capacity"]!.integerValue as Int? {
            lotSpots["hallDirectorTotal"] = hallDirectorTotal
        }
        
        if let miscAvail = lot["Misc_Available"]!.integerValue as Int? {
            lotSpots["miscAvail"] = miscAvail
        }
        if let miscTotal = lot["Misc_Capacity"]!.integerValue as Int? {
            lotSpots["miscTotal"] = miscTotal
        }
        
        if let totalAvail = lot["Total_Available"]!.integerValue as Int? {
            totalSpotsAvailableTextField.text = String(totalAvail)
            lotSpots["totalAvail"] = totalAvail
        }
        if let totalTotal = lot["Total_Capacity"]!.integerValue as Int? {
            totalSpotsTotalTextField.text = String(totalTotal)
            lotSpots["totalTotal"] = totalTotal
        }
        
    }
    
    // Function called when delete lot button pressed... Deletes a lot after user confirmation
    @IBAction func didPressDeleteButton(sender: AnyObject) {
        
        
        
        let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete lot '\(lotNameTextField.text as String!)'?", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            
            // POST method to delete Lot
            CreateLotViewController.deleteLot(self.lotId)
            
            self.performSegueWithIdentifier("unwindToAdminLotsViewController", sender: nil)
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            
            // Do nothing on cancel
            
        }))
        
        presentViewController(deleteAlert, animated: true, completion: nil)
        
        
        
    }
    
    // Function called when save or create button is pressed
    @IBAction func didPressSaveOrCreateButton(sender: AnyObject) {
        
        // If 'managing' use the update lots php middleware file
        if managementType == "Manage" {
            
            // Check if all inputs are integers and entered
            if checkRequiredInputsAreSatisfied() == true {
                
                // POST method to update lot
                
                // Verifies all spot amounts are entered (on both create/save pages)
                if checkAllLotSpotsAreEntered() == true {
                    
                    // Calls update lot function to save lot, returns true on success. If true, return to admin lots view
                    if (CreateLotViewController.createOrSaveLot("http://spacejmu.bitnamiapp.com/SPACEApiCalls/updateLot.php", managementType: managementType, lotName: lotNameTextField.text!, lotLocation: lotLocationTextField.text!, lotId: lotId, lot: lotSpots)) == true {
                        self.performSegueWithIdentifier("unwindToAdminLotsViewController", sender: nil)
                        
                        // else alert user something went wrong
                    } else {
                        alertLabel.text = "Something went wrong!"
                        alertLabel.hidden = false
                        hideAlertLabelAfterTime()
                    }
                    
                    // Further troubleshooting help for user
                } else {
                    if createAttempts > 3 {
                        alertLabel.text = "Check spots on last page"
                    } else {
                        alertLabel.text = "Please enter all spot info"
                    }
                    alertLabel.hidden = false
                    hideAlertLabelAfterTime()
                }
                
            } else {
                
                // Hides alert label after 3 seconds
                
                hideAlertLabelAfterTime()
                
            }

            // If creating a lot, use PHP middleware file for creating lot
        } else if managementType == "Create" {

            // Check if all inputs are integers and entered
            if checkRequiredInputsAreSatisfied() == true {
                
                // POST method to create lot
                
                // Verifies all spot amounts are entered (on both create/save pages)
                if checkAllLotSpotsAreEntered() == true {
                    
                    // Calls create lot function to create lot, returns true on success. If true, return to admin lots view
                    if (CreateLotViewController.createOrSaveLot("http://spacejmu.bitnamiapp.com/SPACEApiCalls/lotCreateIndividual.php", managementType: managementType, lotName: lotNameTextField.text!, lotLocation: lotLocationTextField.text!, lotId: 876325, lot: lotSpots)) == true {
                        self.performSegueWithIdentifier("unwindToAdminLotsViewController", sender: nil)
                        
                        // else alert user something went wrong
                    } else {
                        alertLabel.text = "Something went wrong!"
                        alertLabel.hidden = false
                        hideAlertLabelAfterTime()
                    }
                    
                    // Further troubleshooting help for user
                } else {
                    if createAttempts > 3 {
                        alertLabel.text = "Check spots on last page"
                    } else {
                        alertLabel.text = "Please enter all spot info"
                    }
                    alertLabel.hidden = false
                    hideAlertLabelAfterTime()
                }
                
            } else {
                
                hideAlertLabelAfterTime()
            }
            
        }
        
    }
    
    // Unwind segue to return to this view from next create or save view
    @IBAction func unwindToFirstCreateOrSaveViewController(segue: UIStoryboardSegue) {
    }
    
    // Hides alert label after 3 seconds
    func hideAlertLabelAfterTime() {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.alertLabel.hidden = true
        }
    }

    // Function called on page load to determine whether user is creating or managing a lot and update title accordingly
    func checkCreateOrManageLot() {
        
        if managementType == "Manage" {
            
            lotNameTextField.text = lotName
            
            createOrManageLotTitleLabel.text = "Manage Lot: \(lotName)"
            createOrSaveButtonLabel.setTitle("Save", forState: .Normal)
            
        } else {
            
            createOrManageLotTitleLabel.text = "Create Lot"
            
            createOrSaveButtonLabel.setTitle("Create", forState: .Normal)
            
            deleteButtonLabel.hidden = true
            
        }
        
    }
    
    // Check if all textfields have data and are integers
    func checkRequiredInputsAreSatisfied() -> Bool {
        
        
        if lotNameTextField.text == "" {
            
            alertLabel.text = "Must enter name"
            alertLabel.hidden = false
            
            return false
            
        } else {
            
            alertLabel.hidden = true
            
        }
        
        if lotLocationTextField.text == "" {
            
            alertLabel.text = "Must enter location"
            alertLabel.hidden = false
            
            return false
            
        } else {
            
            alertLabel.hidden = true
            
        }
        
        if let _ = Int(generalSpotsAvailableTextField.text!) {
            
        } else if generalSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(generalSpotsTotalTextField.text!) {
            
        } else if generalSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(generalSpotsAvailableTextField.text!) > Int(generalSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(handicapSpotsAvailableTextField.text!) {
            
        } else if handicapSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(handicapSpotsTotalTextField.text!) {
            
        } else if handicapSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(handicapSpotsAvailableTextField.text!) > Int(handicapSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(meteredSpotsAvailableTextField.text!) {
            
        } else if meteredSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(meteredSpotsTotalTextField.text!) {
            
        } else if meteredSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(meteredSpotsAvailableTextField.text!) > Int(meteredSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(motorcycleSpotsAvailableTextField.text!) {
            
        } else if motorcycleSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(motorcycleSpotsTotalTextField.text!) {
            
        } else if motorcycleSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(motorcycleSpotsAvailableTextField.text!) > Int(motorcycleSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(visitorSpotsAvailableTextField.text!) {
            
        } else if visitorSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(visitorSpotsTotalTextField.text!) {
            
        } else if visitorSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities must be integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(visitorSpotsAvailableTextField.text!) > Int(visitorSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if checkAllLotSpotsAreEntered() == false {
            return false
        }
        
        // Passes all check verifications
        
        createAttempts = 0
        return true
        
    }
    
    // Check if all lot spots have data, not dummy data created (that is, equal to 876325)
    func checkAllLotSpotsAreEntered() -> Bool {
        for (_,value) in lotSpots {
            if value ==  876325 {
                alertLabel.hidden = false
                alertLabel.text = "All spots must have an entry"
                createAttempts += 1
                if createAttempts > 2 {
                    alertLabel.text = "Check spots on next page"
                }

                return false
                
            }
        }
        // If none are "empty" - return true
        return true
    }
    
    // Function able to create or save lots depending on whether the passed in URL is for creating or updating a lot
    class func createOrSaveLot(url: String, managementType: String, lotName: String, lotLocation: String, lotId: Int, lot: Dictionary<String, Int>) -> Bool {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let lotId = lotId
        let genAvail = Int(lot["genAvail"]!)
        let genTotal = Int(lot["genTotal"]!)
        let meteredAvail = Int(lot["meteredAvail"]!)
        let meteredTotal = Int(lot["meteredTotal"]!)
        let visitorAvail = Int(lot["visitorAvail"]!)
        let visitorTotal = Int(lot["visitorTotal"]!)
        let handicapAvail = Int(lot["handicapAvail"]!)
        let handicapTotal = Int(lot["handicapTotal"]!)
        let motorcycleAvail = Int(lot["motorcycleAvail"]!)
        let motorcycleTotal = Int(lot["motorcycleTotal"]!)
        let serviceAvail = Int(lot["serviceAvail"]!)
        let serviceTotal = Int(lot["serviceTotal"]!)
        let housekeepingAvail = Int(lot["housekeepingAvail"]!)
        let housekeepingTotal = Int(lot["housekeepingTotal"]!)
        let hallDirectorAvail = Int(lot["hallDirectorAvail"]!)
        let hallDirectorTotal = Int(lot["hallDirectorTotal"]!)
        let miscAvail = Int(lot["miscAvail"]!)
        let miscTotal = Int(lot["miscTotal"]!)
        let totalAvail = Int(lot["totalAvail"]!)
        let totalTotal = Int(lot["totalTotal"]!)
        
        
        var postString: String! = ""
        
        request.HTTPMethod = "POST"
        
        if managementType == "Manage" {
            
            postString = "lotId=\(lotId)&lotName=\(lotName)&lotLocation=\(lotLocation)&genAvail=\(genAvail)&genTotal=\(genTotal)&meteredAvail=\(meteredAvail)&meteredTotal=\(meteredTotal)&visitorAvail=\(visitorAvail)&visitorTotal=\(visitorTotal)&handicapAvail=\(handicapAvail)&handicapTotal=\(handicapTotal)&motorcycleAvail=\(motorcycleAvail)&motorcycleTotal=\(motorcycleTotal)&serviceAvail=\(serviceAvail)&serviceTotal=\(serviceTotal)&housekeepingAvail=\(housekeepingAvail)&housekeepingTotal=\(housekeepingTotal)&hallDirectorAvail=\(hallDirectorAvail)&hallDirectorTotal=\(hallDirectorTotal)&miscAvail=\(miscAvail)&miscTotal=\(miscTotal)&totalAvail=\(totalAvail)&totalTotal=\(totalTotal)"

        } else {
            
            postString = "lotName=\(lotName)&lotLocation=\(lotLocation)&genAvail=\(genAvail)&genTotal=\(genTotal)&meteredAvail=\(meteredAvail)&meteredTotal=\(meteredTotal)&visitorAvail=\(visitorAvail)&visitorTotal=\(visitorTotal)&handicapAvail=\(handicapAvail)&handicapTotal=\(handicapTotal)&motorcycleAvail=\(motorcycleAvail)&motorcycleTotal=\(motorcycleTotal)&serviceAvail=\(serviceAvail)&serviceTotal=\(serviceTotal)&housekeepingAvail=\(housekeepingAvail)&housekeepingTotal=\(housekeepingTotal)&hallDirectorAvail=\(hallDirectorAvail)&hallDirectorTotal=\(hallDirectorTotal)&miscAvail=\(miscAvail)&miscTotal=\(miscTotal)&totalAvail=\(totalAvail)&totalTotal=\(totalTotal)"
            
        }
            
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                
                print("error=\(error)")
                
                return
                
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                // check for http errors
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                
                print("response = \(response)")
                
            }
            
            CreateLotViewController.responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String

//                        print("Success: ", responseString.containsString("Success"))
          
//                        print("responseString =", responseString)

        }
        
        task.resume()
        
        return true

    }
    
    // Function calling API to delete lot based on the lot's ID
    class func deleteLot(lotId: Int) {
        
//        var responseString = ""
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/deleteLot.php")!)
        
        let postString: String! = "lotId=\(lotId)"
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                
                print("error=\(error)")
                
                return
                
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                // check for http errors
                
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                
                print("response = \(response)")
                
            }
            
            responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
            
//            print("Success?: ", responseString.containsString("Success"))
//            
//            print("responseString =", responseString)
            
        }
        
        task.resume()
        
    }
    
    // Calculate available number of spots if all available spots have data
    func calculateAvailableSpots() {
        // If Int and exists, add text input to lotSpots Dictionary and calculates total
        
        if let genAvail = Int(generalSpotsAvailableTextField.text!) as Int? {
            lotSpots["genAvail"] = genAvail
            
            if let handicapAvail = Int(handicapSpotsAvailableTextField.text!) as Int? {
                lotSpots["handicapAvail"] = handicapAvail
                
                if let meteredAvail = Int(meteredSpotsAvailableTextField.text!) as Int? {
                    lotSpots["meteredAvail"] = meteredAvail
                    
                    if let motorcycleAvail = Int(motorcycleSpotsAvailableTextField.text!) as Int? {
                        lotSpots["motorcycleAvail"] = motorcycleAvail
                        
                        if let visitorAvail = Int(visitorSpotsAvailableTextField.text!) as Int? {
                            lotSpots["visitorAvail"] = visitorAvail
                            
                            if let housekeepingAvail = lotSpots["housekeepingAvail"] as Int? {
                                if housekeepingAvail != 876325 {
                                    
                                    if let serviceAvail = lotSpots["serviceAvail"] as Int? {
                                        if serviceAvail != 876325 {
                                            
                                            if let hallDirectorAvail = lotSpots["hallDirectorAvail"] as Int? {
                                                if hallDirectorAvail != 876325 {
                                                    
                                                    if let miscAvail = lotSpots["miscAvail"] as Int? {
                                                        if miscAvail != 876325 {
                                                            
                                                            if let totalTotal = (genAvail + handicapAvail + meteredAvail + motorcycleAvail + visitorAvail + housekeepingAvail + serviceAvail + hallDirectorAvail + miscAvail) as Int? {
                                                                lotSpots["totalAvail"] = totalTotal
                                                                
                                                                calculateTotalAvailableSpots(totalTotal)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            lotSpots["visitorAvail"] = 876325
                        }
                    } else {
                        lotSpots["motorcycleAvail"] = 876325
                    }
                } else {
                    lotSpots["meteredAvail"] = 876325
                }
            } else {
                lotSpots["handicapAvail"] = 876325
            }
        } else {
            lotSpots["genAvail"] = 876325
        }
    }
    
    // Calculate total number of spots if all available spots have data
    func calculateTotalSpots() {
        if let genTotal = Int(generalSpotsTotalTextField.text!) as Int? {
            lotSpots["genTotal"] = genTotal
            
            if let handicapTotal = Int(handicapSpotsTotalTextField.text!) as Int? {
                lotSpots["handicapTotal"] = handicapTotal
                
                if let meteredTotal = Int(meteredSpotsTotalTextField.text!) as Int? {
                    lotSpots["meteredTotal"] = meteredTotal
                    
                    if let motorcycleTotal = Int(motorcycleSpotsTotalTextField.text!) as Int? {
                        lotSpots["motorcycleTotal"] = motorcycleTotal
                        
                        if let visitorTotal = Int(visitorSpotsTotalTextField.text!) as Int? {
                            lotSpots["visitorTotal"] = visitorTotal
                            
                            if let housekeepingTotal = lotSpots["housekeepingTotal"] as Int? {
                                if housekeepingTotal != 876325 {
                                    
                                    if let serviceTotal = lotSpots["serviceTotal"] as Int? {
                                        if serviceTotal != 876325 {
                                            
                                            if let hallDirectorTotal = lotSpots["hallDirectorTotal"] as Int? {
                                                if hallDirectorTotal != 876325 {
                                                    
                                                    if let miscTotal = lotSpots["miscTotal"] as Int? {
                                                        if miscTotal != 876325 {
                                                        
                                                            if let totalTotal = (genTotal + handicapTotal + meteredTotal + motorcycleTotal + visitorTotal + housekeepingTotal + serviceTotal + hallDirectorTotal + miscTotal) as Int? {
                                                                lotSpots["totalTotal"] = totalTotal
                                                                
                                                                calculateTotalTotalSpots(totalTotal)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            lotSpots["visitorTotal"] = 876325
                        }
                    } else {
                        lotSpots["motorcycleTotal"] = 876325
                    }
                } else {
                    lotSpots["meteredTotal"] = 876325
                }
            } else {
                lotSpots["handicapTotal"] = 876325
            }
        } else {
            lotSpots["genTotal"] = 876325
        }
    }

    // Show and update total available spot text field if all spots are entered
    func calculateTotalAvailableSpots(numberOfAvailableSpots: Int) {

        totalSpotsAvailableTextField.hidden = false
        totalSpotsAvailableTextField.text = String(numberOfAvailableSpots)
        
    }
    
    // Show and update total capacity spot text field if all spots are entered
    func calculateTotalTotalSpots(numberOfTotalSpots: Int) {
        if totalSpotsTotalTextField.hidden == true {
            totalSpotsTotalTextField.hidden = false
        }
        totalSpotsTotalTextField.text = String(numberOfTotalSpots)

    }


    
}
