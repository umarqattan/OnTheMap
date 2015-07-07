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
        deleteSessionID()
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
    
    func deleteSessionID() {
        let urlString = API.Udacity.baseURL + API.Udacity.Methods.session
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var xsrfCookie : NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            if let session = parsedResult["session"] as? [String : AnyObject] {
                if let sessionID = session["id"] as? String {
                    if !sessionID.isEmpty {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.returnToLoginScreen()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            println("SessionID was empty")
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        println("SessionID could not be found")
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    println("Session could not be found")
                }
            }
        }
        task.resume()
    }
    
}