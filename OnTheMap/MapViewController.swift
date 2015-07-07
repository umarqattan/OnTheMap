//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Umar Qattan on 6/27/15.
//  Copyright (c) 2015 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.delegate = self
        self.activityView.hidden = false
        self.activityView.startAnimating()
        self.addStudentInformationsToMap()

    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        
        self.activityView.stopAnimating()
        self.activityView.hidden = true
    }
    
    
    /**
        MARK: return an MKAnnotationView object for pins on the mapView
              that will be reused.
    **/
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "reuseID"
        if annotation.isKindOfClass(MKPointAnnotation.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                let button = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                annotationView.rightCalloutAccessoryView = button
            } else {
                annotationView.annotation = annotation
            }
            return annotationView
        }
        return nil
    }

    /**
        MARK: open a URL (if it is valid, of course) in 
              Safari when the Detail Disclosure UIButton 
              on the MKAnnotationView is tapped.
    **/
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let pointAnnotation = view.annotation as! MKPointAnnotation
        let title = pointAnnotation.title
        let urlString = pointAnnotation.subtitle
        let url = NSURL(string: urlString!)
        if let url = NSURL(string: urlString!) {
            if ( (url.scheme != nil)  && (url.host != nil) ) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    println("Not a valid URL")
                }
            }
        }
    }
    
    /**
        MARK: add pins to the mapView by grabbing the shared
              model's studentInformations:[StudentInformation] 
              array and supplying the pin:MKPointAnnotation
              object with its required properties (i.e. 
              title, subtitle, and coordinate).
    **/
    
    func addStudentInformationsToMap() {
        var studentInformations = (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformations
        for information in studentInformations {
            var pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(information.latitude!, information.longitude!)
            pin.title = information.firstName! + " " + information.lastName!
            pin.subtitle = information.mediaURL!
            mapView.addAnnotation(pin)
            
        }
        activityView.stopAnimating()
        activityView.hidden = true
    }
}