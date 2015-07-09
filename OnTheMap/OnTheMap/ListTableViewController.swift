//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Umar Qattan on 6/27/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class ListTableViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
        reloadStudentInformations()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadStudentInformations()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    /**
        MARK: Configure tableView when view loads,
              reload shared object localUdacityProfiles,
              parse Parse JSON object, and add a 
              udacityProfile object to the AppDelegate's
              data store.
    **/

    func reloadStudentInformations() {
        
        dispatch_async(dispatch_get_main_queue()) {
            var top = self.topLayoutGuide.length;
            var bottom = self.bottomLayoutGuide.length;
            var newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
            self.tableView.contentInset = newInsets
            self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
            self.tableView.reloadData()
        }
       
    }
    
    func addStudentInformationToAppDelegate(studentInformation : StudentInformation) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations.append(studentInformation)
    }
    
    /**
        MARK: UITableView protocol methods
    **/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations.count
    }
    
    
    /**
        MARK: Add prefix
    **/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInformation = (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations[indexPath.row] as StudentInformation
        if let mediaURL = studentInformation.mediaURL {
            if let url = NSURL(string: mediaURL) {
                if (url.scheme != nil) && (url.host != nil) {
                    UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        println("Not a valid URL")
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UdacityProfileTableViewCell") as! UdacityProfileTableViewCell
        let studentInformation = (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations[indexPath.row]
        let name = studentInformation.firstName! + " " + studentInformation.lastName!
        let mediaURL = studentInformation.mediaURL!
        let mapString = studentInformation.mapString!
        cell.udacityProfileTitleLabel.text = name
        return cell
    }
    
}