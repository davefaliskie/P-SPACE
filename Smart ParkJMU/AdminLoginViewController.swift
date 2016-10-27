//
//  AdminLoginViewController.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 1/24/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import UIKit

class AdminLoginViewController: UIViewController, UITextFieldDelegate {
    
    // Lot views labels
    @IBOutlet weak var usernameOrEmailInputTextField: UITextField!
    @IBOutlet weak var passwordInputTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function run when view is loading
    func setup() {
        // Sets username and password text fields delegated to this view controller
        self.passwordInputTextField.delegate = self
        self.usernameOrEmailInputTextField.delegate = self
        
        // Alert label hidden to start, and makes corners round
        alertLabel.hidden = true
        alertLabel.layer.masksToBounds = true;
        alertLabel.layer.cornerRadius = 19;
    }
    
    // If user touches somewhere other than a text field hides keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hides keyboard after pressing enter/return on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Function run when login button pressed
    @IBAction func didPressLoginButton(sender: AnyObject) {
        
        let usernameInput = usernameOrEmailInputTextField.text
        let passwordInput = passwordInputTextField.text
        
        if login(usernameInput!, password: passwordInput!) == true {
            
            performSegueWithIdentifier("segueToAdminLotsView", sender: nil)
            
            globalVar.loggedIn = true
            
        } else if alertLabel.hidden == true {
            
            alertLabel.hidden = false
            
        }
        
    }
    
    // Checks if both username and password textfields are satisfied
    func checkAccountCredentials() -> Bool {
        
        if checkUsernameOrEmailCredentials() && checkPasswordCredentials() == true {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    // If username textfield is not satisfied, user will be alerted
    func checkUsernameOrEmailCredentials() -> Bool {
        
        if usernameOrEmailInputTextField.text!.isEmpty {
            
            alertLabel.text = "Please enter your email."
            alertLabel.hidden = false
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.alertLabel.hidden = true
            }
            
            return false
            
        } else {
            
            alertLabel.hidden = true
            
            return true
            
        }
        
    }
    
    // If password textfield is not satisfied, user will be alerted
    func checkPasswordCredentials() -> Bool {
        
        if passwordInputTextField.text!.isEmpty {
            
            alertLabel.text = "Please enter your password."
            alertLabel.hidden = false
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.alertLabel.hidden = true
            }
            
            return false
            
        } else {
            
            alertLabel.hidden = true
            
            return true
            
        }
        
    }
    
    // Function to check if the email and passwords entered from user are in the database
    func login(email: String, password: String) -> Bool {
        
        // If both email and password textfields are satisfied, continue with login verification
        if checkAccountCredentials() == true {
            
            var responseString = ""
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://spacejmu.bitnamiapp.com/SPACEApiCalls/loginUser.php")!)
            
            request.HTTPMethod = "POST"
            
            let postString = "email=\(email)&password=\(password)"
            
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let semaphore = dispatch_semaphore_create(0)
            
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
                
//                print("Success?: ", responseString.containsString("Success"))
                
//                print("responseString =", responseString)
                
                if (responseString.containsString("incorrect")) || (responseString.containsString("exist")) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alertLabel.text = responseString
                        self.alertLabel.hidden = false
                    })
                    
                }
                
                dispatch_semaphore_signal(semaphore)
                
            }
            
            task.resume()
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            return responseString.containsString("Success")
            
        } else {
            
            return false
            
        }
        
    }
    
    // Unwind to admin login view from the admin lots page
    @IBAction func unwindToAdminLoginViewController(segue: UIStoryboardSegue) {
    }
    
}
