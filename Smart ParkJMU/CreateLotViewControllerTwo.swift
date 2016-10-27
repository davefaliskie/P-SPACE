//
//  CreateLotViewControllerTwo.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 3/15/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class CreateLotViewControllerTwo: UIViewController {

    // Labels
    @IBOutlet weak var createOrManageLotTitleLabel: UILabel!
    @IBOutlet weak var createOrSaveButtonLabel: UIButton!
    
    @IBOutlet weak var deleteButtonLabel: UIButton!
    
    @IBOutlet weak var lotNameTextField: UITextField!
    @IBOutlet weak var lotLocationTextField: UITextField!
    
    @IBOutlet weak var alertLabel: UILabel!
    
    // Spot Available/Total Text Fields
    @IBOutlet weak var housekeepingSpotsAvailableTextField: UITextField!
    @IBOutlet weak var housekeepingSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var serviceSpotsAvailableTextField: UITextField!
    @IBOutlet weak var serviceSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var hallDirectorSpotsAvailableTextField: UITextField!
    @IBOutlet weak var hallDirectorSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var miscSpotsAvailableTextField: UITextField!
    @IBOutlet weak var miscSpotsTotalTextField: UITextField!
    
    @IBOutlet weak var totalSpotsAvailableTextField: UILabel!
    @IBOutlet weak var totalSpotsTotalTextField: UILabel!
    
    // Lot Instance
    var lotId = Int()
    var lotName = String()
    var lotLocation = String()
    
    var managementType = String()
    var createAttempts: Int = 0
    
    var lotSpots = Dictionary<String, Int>()
    
    // After editing any available spot info, calculate total number of entered available spots if all lot spots are filled
    @IBAction func finishedEditingAvailableSpots(sender: UITextField) {
        calculateAvailableSpots()
    }
    
    // After editing any capacity spot info, calculate total number of entered capacity spots if all lot spots are filled
    @IBAction func finishedEditingTotalSpots(sender: AnyObject) {
        calculateTotalSpots()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Function run when view is initially loaded
        viewSetup()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Closes keyboard when touching background
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // If segueing to previous create or save lots view, pass lot data from current page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? CreateLotViewController {
            destination.managementType = managementType
            destination.lotName = lotNameTextField.text!
            destination.lotLocation = lotLocationTextField.text!
            destination.lotSpots = lotSpots
            
            destination.calculateAvailableSpots()
            destination.calculateTotalSpots()
        }
    }
    
    // Function called when save or create button is pressed
    @IBAction func didPressCreateOrSaveButton(sender: AnyObject) {
        
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
                    
                } else {
                    // Further troubleshooting help for user
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
                
                // If all good, hide alert label
                hideAlertLabelAfterTime()
            }
            
        }
        
    }
    
    // Function called on page load
    func viewSetup() {
        
        // Check whether user is managing or creating a lot
        checkCreateOrManageLot()
        
        // Hide calculated totals label unless all fields are entered
        if checkAllLotSpotsAreEntered() == false {
            totalSpotsAvailableTextField.hidden = true
            totalSpotsTotalTextField.hidden = true
        }
        
        // Hides and makes alert label corner round
        alertLabel.hidden = true
        alertLabel.layer.masksToBounds = true;
        alertLabel.layer.cornerRadius = 19;
        
        // If lotName is not empty, set the lotname textfield to lotName
        if !(lotName.isEmpty) {
            lotNameTextField.text = lotName
        }
        
        // If lotLocation is not empty, set the lotLocation textfield to lotLocation
        if !(lotLocation.isEmpty) {
            lotLocationTextField.text = lotLocation
        }
        
        // Set all textfields to according data pulled from GET
        updateLotSpots()
        
    }
    
    // Hides alert label after 3 seconds
    func hideAlertLabelAfterTime() {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.alertLabel.hidden = true
        }
    }

    // Function to determine whether managing or creating a lot. Setting variable and title accordingly
    func checkCreateOrManageLot() {
        
        if managementType == "Manage" {
            
            createOrManageLotTitleLabel.text = "Manage Lot: \(lotName)..."
            createOrSaveButtonLabel.setTitle("Save", forState: .Normal)
            
            //            updateLotLabels()
            
        } else {
            
            createOrManageLotTitleLabel.text = "Create Lot..."
            
            createOrSaveButtonLabel.setTitle("Create", forState: .Normal)
            
            deleteButtonLabel.hidden = true
            
        }
        
    }
    
    // Sets all textfields to appropriate data if not equal to 876325 (created value for verifying data)
    func updateLotSpots() {
        
        if let housekeepingAvail = lotSpots["housekeepingAvail"] as Int? {
            if housekeepingAvail != 876325 {
                housekeepingSpotsAvailableTextField.text = String(housekeepingAvail)
            }
        }
        
        if let housekeepingTotal = lotSpots["housekeepingTotal"] as Int? {
            if housekeepingTotal != 876325 {
                housekeepingSpotsTotalTextField.text = String(housekeepingTotal)
            }
        }
        
        if let serviceAvail = lotSpots["serviceAvail"] as Int? {
            if serviceAvail != 876325 {
                serviceSpotsAvailableTextField.text = String(serviceAvail)
            }
        }

        if let serviceTotal = lotSpots["serviceTotal"] as Int? {
            if serviceTotal != 876325 {
                serviceSpotsTotalTextField.text = String(serviceTotal)
            }
        }
        
        if let hallDirectorAvail = lotSpots["hallDirectorAvail"] as Int? {
            if hallDirectorAvail != 876325 {
                hallDirectorSpotsAvailableTextField.text = String(hallDirectorAvail)
            }
        }
        
        if let hallDirectorTotal = lotSpots["hallDirectorTotal"] as Int? {
            if hallDirectorTotal != 876325 {
                hallDirectorSpotsTotalTextField.text = String(hallDirectorTotal)
            }
        }
        
        if let miscAvail = lotSpots["miscAvail"] as Int? {
            if miscAvail != 876325 {
                miscSpotsAvailableTextField.text = String(miscAvail)
            }
        }
        
        if let miscTotal = lotSpots["miscTotal"] as Int? {
            if miscTotal != 876325 {
                miscSpotsTotalTextField.text = String(miscTotal)
            }
        }
        
        if let totalAvail = lotSpots["totalAvail"] as Int? {
            if totalAvail != 876325 {
                totalSpotsAvailableTextField.text = String(totalAvail)
            } else {
                totalSpotsAvailableTextField.hidden = true
            }
        }
        
        if let totalTotal = lotSpots["totalTotal"] as Int? {
            if totalTotal != 876325 {
                totalSpotsTotalTextField.text = String(totalTotal)
            } else {
                totalSpotsTotalTextField.hidden = true
            }
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
        
        if let _ = Int(housekeepingSpotsAvailableTextField.text!) {
            
        } else if housekeepingSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(housekeepingSpotsTotalTextField.text!) {
            
        } else if housekeepingSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(housekeepingSpotsAvailableTextField.text!) > Int(housekeepingSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(serviceSpotsAvailableTextField.text!) {
            
        } else if serviceSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(serviceSpotsTotalTextField.text!) {
            
        } else if serviceSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(serviceSpotsAvailableTextField.text!) > Int(serviceSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(hallDirectorSpotsAvailableTextField.text!) {
            
        } else if hallDirectorSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(hallDirectorSpotsTotalTextField.text!) {
            
        } else if hallDirectorSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(hallDirectorSpotsAvailableTextField.text!) > Int(hallDirectorSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if let _ = Int(miscSpotsAvailableTextField.text!) {
            
        } else if miscSpotsAvailableTextField.text == "" {
            
            alertLabel.text = "Enter all spot availabilities"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if let _ = Int(miscSpotsTotalTextField.text!) {
            
        } else if miscSpotsTotalTextField.text == "" {
            
            alertLabel.text = "Enter all spot totals"
            alertLabel.hidden = false
            return false
            
        } else {
            
            alertLabel.text = "Spot availabilities aren't integers"
            alertLabel.hidden = false
            return false
        }
        
        if Int(miscSpotsAvailableTextField.text!) > Int(miscSpotsTotalTextField.text!)  {
            
            alertLabel.text = "Available spots must be less than total"
            alertLabel.hidden = false
            return false
            
        }
        
        if checkAllLotSpotsAreEntered() == false {
            alertLabel.hidden = false
            if createAttempts > 3 {
                alertLabel.text = "Check spots on last page"
            } else {
                alertLabel.text = "Please enter all spot info"
            }
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
                createAttempts += 1
               
                return false
                
            }
        }
        // If none are "empty" - return true
        return true
    }
    
    // Calculate available number of spots if all available spots have data
    func calculateAvailableSpots() {
        // If Int and exists, add text input to lotSpots Dictionary and calculates total
        
        if let genAvail = lotSpots["genAvail"] as Int? {
            if genAvail != 876325 {
                
                if let handicapAvail = lotSpots["handicapAvail"] as Int? {
                    if handicapAvail != 876325 {
                        
                        if let meteredAvail = lotSpots["meteredAvail"] as Int? {
                            if meteredAvail != 876325 {
                                
                                if let motorcycleAvail = lotSpots["motorcycleAvail"] as Int? {
                                    if motorcycleAvail != 876325 {
                                        
                                        if let visitorAvail = lotSpots["visitorAvail"] as Int? {
                                            if visitorAvail != 876325 {
                                                
                                                if let housekeepingAvail = Int(housekeepingSpotsAvailableTextField.text!) as Int? {
                                                    lotSpots["housekeepingAvail"] = housekeepingAvail
                                                    
                                                    if let serviceAvail = Int(serviceSpotsAvailableTextField.text!) as Int? {
                                                        lotSpots["serviceAvail"] = serviceAvail
                                                        
                                                        if let hallDirectorAvail = Int(hallDirectorSpotsAvailableTextField.text!) as Int? {
                                                            lotSpots["hallDirectorAvail"] = hallDirectorAvail
                                                            
                                                            if let miscAvail = Int(miscSpotsAvailableTextField.text!) as Int? {
                                                                lotSpots["miscAvail"] = miscAvail
                                                                
                                                                if let totalAvail = (genAvail + handicapAvail + meteredAvail + motorcycleAvail + visitorAvail + housekeepingAvail + serviceAvail + hallDirectorAvail + miscAvail) as Int? {
                                                                    lotSpots["totalAvail"] = totalAvail
                                                                    
                                                                    calculateTotalAvailableSpots(totalAvail)
                                                                }
                                                            } else {
                                                                lotSpots["miscAvail"] = 876325
                                                            }
                                                        } else {
                                                            lotSpots["hallDirectorAvail"] = 876325
                                                        }
                                                    } else {
                                                        lotSpots["serviceAvail"] = 876325
                                                    }
                                                } else {
                                                    lotSpots["housekeepingAvail"] = 876325
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // Calculate total number of spots if all available spots have data
    func calculateTotalSpots() {
        // If Int and exists, add text input to lotSpots Dictionary and calculates total
        if let genTotal = lotSpots["genAvail"] as Int? {
            if genTotal != 876325 {
                
                if let handicapTotal = lotSpots["handicapAvail"] as Int? {
                    if handicapTotal != 876325 {
                        
                        if let meteredTotal = lotSpots["meteredAvail"] as Int? {
                            if meteredTotal != 876325 {
                                
                                if let motorcycleTotal = lotSpots["motorcycleAvail"] as Int? {
                                    if motorcycleTotal != 876325 {
                                        
                                        if let visitorTotal = lotSpots["visitorAvail"] as Int? {
                                            if visitorTotal != 876325 {
                                                
                                                if let housekeepingTotal = Int(housekeepingSpotsTotalTextField.text!) as Int? {
                                                    lotSpots["housekeepingTotal"] = Int(housekeepingSpotsTotalTextField.text!)!
                                                    
                                                    if let serviceTotal = Int(serviceSpotsTotalTextField.text!) as Int? {
                                                        lotSpots["serviceTotal"] = Int(serviceSpotsTotalTextField.text!)!
                                                        
                                                        if let hallDirectorTotal = Int(hallDirectorSpotsTotalTextField.text!) as Int? {
                                                            lotSpots["hallDirectorTotal"] = Int(hallDirectorSpotsTotalTextField.text!)!
                                                            
                                                            if let miscTotal = Int(miscSpotsTotalTextField.text!) as Int? {
                                                                lotSpots["miscTotal"] = Int(miscSpotsTotalTextField.text!)!
                                                                
                                                                if let totalTotal = (genTotal + handicapTotal + meteredTotal + motorcycleTotal + visitorTotal + housekeepingTotal + serviceTotal + hallDirectorTotal + miscTotal) as Int? {
                                                                    lotSpots["totalTotal"] = totalTotal
                                                                    
                                                                    calculateTotalTotalSpots(totalTotal)
                                                                }
                                                            } else {
                                                                lotSpots["miscTotal"] = 876325
                                                            }
                                                        } else {
                                                            lotSpots["hallDirectorTotal"] = 876325
                                                        }
                                                    } else {
                                                        lotSpots["serviceTotal"] = 876325
                                                    }
                                                } else {
                                                    lotSpots["housekeepingTotal"] = 876325
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Show and update total available spot text field if all spots are entered
    func calculateTotalAvailableSpots(numberOfAvailableSpots: Int) {
        
        if totalSpotsAvailableTextField.hidden == true {
            totalSpotsAvailableTextField.hidden = false
        }
        
        totalSpotsAvailableTextField.text = String(numberOfAvailableSpots)

        if createAttempts > 3 {
            alertLabel.text = "Check spots on last page"
        } else {
            alertLabel.text = "Please enter all spot info"
        }
    }

    // Show and update total capacity spot text field if all spots are entered
    func calculateTotalTotalSpots(numberOfTotalSpots: Int) {
        
        if totalSpotsTotalTextField.hidden == true {
            totalSpotsTotalTextField.hidden = false
        }
        
        totalSpotsTotalTextField.text = String(numberOfTotalSpots)
        
        if createAttempts > 3 {
            alertLabel.text = "Check spots on last page"
        } else {
            alertLabel.text = "Please enter all spot info"
        }
    
    }
}
