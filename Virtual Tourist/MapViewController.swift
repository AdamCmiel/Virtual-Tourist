//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let kPinReuseIdentifier = "pin"

class MapViewController: UIViewController, MKMapViewDelegate {

    var detailAnnotation: MKAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func onLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began else { return }
        
        let touchPoint: CGPoint = sender.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let pin = Pin.create()
        pin.longitude = touchMapCoordinate.longitude
        pin.latitude = touchMapCoordinate.latitude
        pin.getPhotosFromFlickr()
        saveCoreData()
        
        mapView.addAnnotation(pin)
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mapView.setRegion(MapPersistence.region, animated: false)
        mapView.addAnnotations(MapPersistence.annotations)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPinDetail" {
            if let dvc = segue.destinationViewController as? LocationDetailViewController {
                let pin = detailAnnotation as! Pin
                dvc.annotation = pin
                pin.delegate = dvc
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kPinReuseIdentifier)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        detailAnnotation = view.annotation
        performSegueWithIdentifier("showPinDetail", sender: view)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        MapPersistence.region = mapView.region
    }
    
}

