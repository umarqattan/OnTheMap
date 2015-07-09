//
//  MapListTabBarController.swift
//  OnTheMap
//
//  Created by Umar Qattan on 6/28/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapListTabBarController : UITabBarController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
    var informationPostingPinBarButtonItem : UIBarButtonItem!
    var informationPostingPinBarButtonItemImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Added a pin bar button on navigation bar  **/
        
        informationPostingPinBarButtonItemImage = UIImage(named: "Pin-25")
        informationPostingPinBarButtonItem = UIBarButtonItem(image: informationPostingPinBarButtonItemImage,
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: Selector("markTheMapWithAPin:"))
        navigationItem.rightBarButtonItems = [refreshBarButtonItem, informationPostingPinBarButtonItem]
        getInfo()
    }
    
    
    /**
        MARK: Add functionality to UIBarButtonItems such as
              logout, refresh, and pin
    **/
    
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
    
    @IBAction func logout(sender: UIBarButtonItem) {
        loggingOut()
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        getInfo()
    }
    
    func returnToLoginScreen() {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func markTheMapWithAPin(sender : AnyObject) {
        let informationPostingViewController = storyboard?.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        presentViewController(informationPostingViewController, animated: true, completion: nil)
    }
    
    
    /**
        MARK: Function to ensure secure logout
    **/
    
    func loggingOut() {
        UdacityLogin().secureLogOut() { success, downloadError in
            if success {
                self.returnToLoginScreen()
            } else {
                var message = "There was a problem logging out. Try again later"
                let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
}