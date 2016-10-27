//
//  UserRegistrationViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 2/22/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class UserRegistrationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // View textfields
    @IBOutlet weak var nameTextInputField: UITextField!
    @IBOutlet weak var emailTextInputField: UITextField!
    @IBOutlet weak var passwordTextInputField: UITextField!
    @IBOutlet weak var confirmPasswordTextInputField: UITextField!
    @IBOutlet weak var permitTypePicker: UIPickerView!
    @IBOutlet weak var alertLabel: UILabel!
    
    // Instance variables
    var email = String()
    var firstName = String()
    var lastName = String()
    var password = String()
    var permitType = String()
    var carType = String()
    
    // Permit and car types for user to select when registering
    let permitTypes: [[String]] = [["Commuter", "Resident", "Red Zone", "Blue Zone", "Freshman"],
                                   ["None", "Handicap", "Motorcycle", "Service", "Housekeeping", "Hall Director"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    // If user touches somewhere other than a text field hides keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hides keyboard after hitting return on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function run when view is loading
    func setup() {
        // Sets permit and car type picker datasource and delegate to the controller
        self.permitTypePicker.delegate = self
        self.permitTypePicker.dataSource = self
        
        // Sets textfield delegates to controller for textFieldShouldReturn function
        self.nameTextInputField.delegate = self
        self.emailTextInputField.delegate = self
        self.passwordTextInputField.delegate = self
        self.confirmPasswordTextInputField.delegate = self
        
        // Hides alert label to start
        alertLabel.hidden = true
        
        // Makes alert label corners round
        alertLabel.layer.masksToBounds = true;
        alertLabel.layer.cornerRadius = 19;
    }
    
    // Permit and car type picker configuration: Sets 2 columns, permit type and car type
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // Permit and car type picker configuration: Sets number of rows to the length of permitTypes array
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return permitTypes[component].count
    }
    
    // Permit and car type picker configuration: Sets row titles to permit and car types
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return permitTypes[component][row]
    }

    // Function run when register button pressed
    @IBAction func didPressRegister(sender: AnyObject) {
        
        // Checks if all textfields and values are entered and satisfied
        if checkCredentials() == true {
            
            // If textfields and values are entered and satisfied, run createUser function
            createUser()
            self.performSegueWithIdentifier("goToLogin", sender: nil)
            alertLabel.hidden = true
        }
    }
    
    // Function to check if full name is entered, using Regular Expressions
    func checkName() -> Bool {
        if (nameTextInputField.text!.isEmpty) {
            
            alertLabel.hidden = false
            alertLabel.text = "Enter your full name."
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 2 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.alertLabel.hidden = true
            }
            return false
            
        } else {
            
            let nameRegEx = "[A-Za-z]+\\s[A-Za-z]+"
            let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
            let result = nameTest.evaluateWithObject(nameTextInputField.text!)
            
//            print("check name", result)
            
            if result == true {
            
                // Separates Name into array of first and last name separately
                let fullNameArray = nameTextInputField.text!.componentsSeparatedByString(" ")
            
                firstName = fullNameArray[0] // First
                lastName = fullNameArray[1] // Last
                
                alertLabel.hidden = true
                
                return true
            } else {
                
                alertLabel.hidden = false
                alertLabel.text = "Must enter 'First Last' Names."
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.alertLabel.hidden = true
                }
                
                return false
            }
        }
    }
    
    // Function to check email textfield is entered, using Regular Expressions
    func checkEmail() -> Bool {
        
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluateWithObject(emailTextInputField.text!)
        
        // print("check email", result)
        
        email = emailTextInputField.text!
        
        if result == false {
            alertLabel.hidden = false
            alertLabel.text = "Incorrect email address!"
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.alertLabel.hidden = true
            }
            
            return false
        } else {
            return true
        }

    }
    
    // Function to check passwords are entered, and if they are the same
    func checkPassword() -> Bool {
        
        if (passwordTextInputField.text == confirmPasswordTextInputField.text) && (passwordTextInputField.text! != "") && (confirmPasswordTextInputField.text! != "") {
            
            password = confirmPasswordTextInputField.text!
            
            return true
            
        } else {
            alertLabel.hidden = false
            alertLabel.text = "Passwords don't match!"
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.alertLabel.hidden = true
            }
            
            return false
        }
    
    }
    
    // Sets permit and car type variables to the selected permit and car types selected from picker view
    func checkPickerValues() {
        permitType = permitTypes[0][permitTypePicker.selectedRowInComponent(0)]
        carType = permitTypes[1][permitTypePicker.selectedRowInComponent(1)]
    }
    
    // Checks if all textfields and entries are satisfied
    func checkCredentials() -> Bool {
        
        if checkName() && checkEmail() && checkPassword() == true {
            checkPickerValues()
            return true
        } else {
            return false
        }
    }

    // Function to register user in database
    func createUser() {
        
        var responseString = ""
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/userRegister.php")!)
        
        let postString = "email=\(email)&password=\(password)&firstName=\(firstName)&lastName=\(lastName)&permitType=\(permitType)&carType=\(carType)"
        
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

//            print("responseString =", responseString)
            
            // If a user is registered with that email address, it sets the alertlabel to alert the user
            if responseString.containsString("exists") {
                dispatch_async(dispatch_get_main_queue(), {
                    self.alertLabel.text = responseString
                    self.alertLabel.hidden = false
                })
            }
        }
        task.resume()
    }
}
