//
//  LocationDetailViewController.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailViewController: UIViewController, PhotoReciever {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var button: UIButton!
    
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func photoFetcher(fetcher: Fetcher, didFetchPhotoAtDiskURL: String) {
        // refresh collection from annotation
    }
}
