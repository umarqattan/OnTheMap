//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Umar Qattan on 6/27/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationPostingViewController : UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var locationNameView: UIView!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var annotation : MKAnnotation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    /**
        MARK: View controller buttons to find the
              desired location on the map, submit
              (POST) to Parse, or cancel posting
              information to Parse.
    **/

    
    @IBAction func findOnTheMap(sender: UIButton) {
        
        
        findOnTheMapButton.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        getGeocodeWithAddress()
    }
    
    @IBAction func submit(sender: UIButton) {
        
        self.submitButton.hidden = true
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        if let mediaURL = linkTextfield.text {
            if let url = NSURL(string: mediaURL) {
                if (url.scheme != nil) && (url.host != nil) {
                    ParseStudentInformation().POSTStudentInformation(buildInfoTableBody()) { success, downloadError in
                        if let error = downloadError {
                            dispatch_async(dispatch_get_main_queue()) {
                                var message = "Could not add pin to the map"
                                let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                                let alertAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Cancel) { UIAlertAction in
                                    self.submitButton.hidden = false
                                }
                                alertController.addAction(alertAction)
                                self.activityIndicator.hidden = true
                                self.activityIndicator.stopAnimating()
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                var message = "Successfully added a pin to the map!"
                                let alertController = UIAlertController(title: "Success", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                                let alertAction = UIAlertAction(title: "Awesome!", style: UIAlertActionStyle.Cancel) { UIAlertAction in
                                    var student = self.buildInfoTableBody()
                                    var postStudentInformation = StudentInformation(dictionary: student)
                                    (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations.append(postStudentInformation)
                                    self.submitButton.hidden = false
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                alertController.addAction(alertAction)
                                self.activityIndicator.hidden = true
                                self.activityIndicator.stopAnimating()
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        var message = "The link provided was invalid"
                        let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                        let alertAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Cancel) { UIAlertAction in
                            self.submitButton.hidden = false
                            self.submitButton.enabled = false
                            self.linkTextfield.text = "Enter a link to share"
                        }
                        alertController.addAction(alertAction)
                        self.activityIndicator.hidden = true
                        self.activityIndicator.stopAnimating()
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
        }

        
        
    }
    
    func buildInfoTableBody() -> [String: AnyObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return [
                "firstName": appDelegate.user!.firstName,
                "lastName": appDelegate.user!.lastName,
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude,
                "mapString": locationTextfield.text,
                "mediaURL": linkTextfield.text,
                "uniqueKey": appDelegate.user!.id
            ]
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        MARK: POSTing a student location, setting
              the delegates, and configuring the UI
              helper functions.
    **/
    
    
    func setDelegates() {
        mapView.delegate = self
        locationTextfield.delegate = self
        linkTextfield.delegate = self
    }
    
    func configureUI() {
        findOnTheMapButton.enabled = false
        submitButton.enabled = false
        submitButton.hidden = true
        activityIndicator.hidden = true
        mapView.hidden = true
        linkTextfield.enabled = false
        linkTextfield.hidden = true
        activityIndicator.hidden = true
    }
    
    func configureUIViews() {
        cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        
        topView.backgroundColor = UIColor(red: 0.2, green: 0.576, blue: 0.824, alpha: 1.0)
        
        locationNameView.removeFromSuperview()
        
        locationTextfield.enabled = false
        locationTextfield.hidden = true
        
        submitButton.hidden = false
        submitButton.enabled = false
        submitButton.bringSubviewToFront(bottomView)
        
        bottomView.opaque = false
        bottomView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        view.bringSubviewToFront(mapView)
        view.bringSubviewToFront(bottomView)
        mapView.bringSubviewToFront(bottomView)
        mapView.bringSubviewToFront(submitButton)
        mapView.bringSubviewToFront(activityIndicator)
        bottomView.bringSubviewToFront(activityIndicator)
        submitButton.bringSubviewToFront(activityIndicator)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        
        
        mapView.hidden = false
        
        questionLabel.hidden = true
        questionLabel.removeFromSuperview()
        
        linkTextfield.hidden = false
        linkTextfield.enabled = true
    }
    
    func getGeocodeWithAddress() {
            var address = locationTextfield.text
            var geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
            dispatch_async(dispatch_get_main_queue()) {
                self.annotation = MKPlacemark(placemark: placemark)
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                self.mapView.showAnnotations([self.annotation], animated: true)
                self.findOnTheMapButton.hidden = true
                self.activityIndicator.hidden = true
                self.configureUIViews()
                self.activityIndicator.stopAnimating()
                self.submitButton.enabled = true
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    var message = "Geocoding failed to address your desired location"
                    let alertController = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.activityIndicator.hidden = true
                    self.submitButton.bringSubviewToFront(self.activityIndicator)
                    self.findOnTheMapButton.hidden = false
                    self.activityIndicator.stopAnimating()
                    
                }
            }
        })
    }
    /**
        MARK: UITextField delegate protocol methods
    **/
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == locationTextfield {
            textField.text = ""
        } else if textField == linkTextfield {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == locationTextfield && textField.text.isEmpty {
            textField.text = "Enter a location"
        } else {
            findOnTheMapButton.enabled = true
        }
        if textField == linkTextfield && textField.text.isEmpty {
            textField.text = "Enter a link to share"
        }
        submitButton.enabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
}