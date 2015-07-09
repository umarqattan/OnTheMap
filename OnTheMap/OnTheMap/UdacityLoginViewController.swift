//
//  UdacityLoginViewController.swift
//  OnTheMap
//
//  Created by Umar Qattan on 6/26/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import UIKit

class UdacityLoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInWithFacebookButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var keyboardDismissTapGesture : UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UdacityLogin().getAppDelegate().user = User(dictionary: [:])
        activityIndicator.hidden = true
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        toggleLoginButton(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleLoginButton(false)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        cleanTextfields()
    }
    

    @IBAction func login(sender: UIButton) {
        loggingIn()
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()){
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("navigationController") as! UINavigationController
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func loggingIn() {
        UdacityLogin().secureLogin(emailTextfield.text, password: passwordTextfield.text) { success, downloadError in
            if success {
                var user = UdacityLogin().getAppDelegate().user
                UdacityLogin().getUserInformation(user!.key) { success, downloadError in
                    if success {
                        var infoAPI = ParseStudentInformation()
                        infoAPI.GETStudentInformation(){ (info, success, error) in
                            if success{
                                (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations = info!
                                self.completeLogin()
                            } else {
                                var message = error
                                let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                                let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                                alertController.addAction(alertAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.displayAlertController("Error", message: downloadError!)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                    }
                }
            } else {
                self.displayAlertController("Error", message: downloadError!)
            }
        }
    }
    
    func getInfo() {
        var infoAPI = ParseStudentInformation()
        infoAPI.GETStudentInformation(){ (info, success, error) in
            if success{
                (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations = info!
            } else {
                var message = error
                let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func displayAlertController(title : String, message : String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) { UIAlertAction in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    /**
    MARK: UITapGestureRecognizer methods to dismiss the keyboard
    when the surrounding view is tapped.
    **/
    
    func dismissKeyboard(sender : AnyObject) {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
    
    /**
    MARK: If there is a keyboard being used, a tap gesture recognizer
    will be initialized. Its purpose is to dismiss the keyboard.
    If the tap gesture recognizer is still on the view, even
    when there is no keyboard, then deinitialize the gesture
    recognizer.
    **/
    func keyboardWillShow(notification : NSNotification) {
        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
            view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        if keyboardDismissTapGesture != nil {
            view.removeGestureRecognizer(keyboardDismissTapGesture!)
            keyboardDismissTapGesture = nil
        }
    }
    /**
    MARK: Subscribe/Unsubscribe to/from keyboard notifications
    **/
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    /** MARK: Clean up textfields when the view appears **/
    
    func cleanTextfields() {
        emailTextfield.text = "Email"
        passwordTextfield.text = "Password"
        passwordTextfield.secureTextEntry = false
    }
    
    /**
    MARK: Tell the application to suspend activity to open
    Safari that redirects the user to the Udacity
    sign up page.
    **/
    
    @IBAction func signUp(sender: UIButton) {
        let signUpURLString = "https://www.udacity.com/account/auth#!/signup"
        let signUpURL = NSURL(string: signUpURLString)!
        UIApplication.sharedApplication().openURL(signUpURL)
    }
    
    /** MARK: Toggle Login button **/
    
    func toggleLoginButton(enable: Bool) {
        loginButton.enabled = enable
    }
    
    /** MARK: UITextFieldDelegate protocol methods **/
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == emailTextfield {
            textField.text = ""
        }
        if textField == passwordTextfield {
            textField.text = ""
            textField.secureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == emailTextfield && textField.text.isEmpty {
            textField.text = "Email"
        } else if textField == passwordTextfield && textField.text.isEmpty {
            textField.secureTextEntry = false
            textField.text = "Password"
        }
        toggleLoginButton(true)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}