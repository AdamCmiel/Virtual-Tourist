//
//  LocationDetailViewController.swift
//  Virtual Tourist
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit

let detailCollectionViewReuseIdentifier = "cell"
let newCollectionDetailLabel = "New Collection"
let downloadingButtonLabel = "Downloading"

class LocationDetailViewController: UIViewController, PhotoReciever, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func collectionButtonPressed(sender: AnyObject) {
        let pin = annotation!
        pin.removePhotos(pin.photos!)
        //pin.getPhotos()
        
        downloadButton.setTitle(downloadingButtonLabel, forState: .Normal)
        downloadButton.setTitle(downloadingButtonLabel, forState: .Selected)
        downloadButton.setTitle(downloadingButtonLabel, forState: .Disabled)
        downloadButton.enabled = false
    }
    
    var annotation: Pin?
    
    var photos: [Photo] {
        let pinAnnotation = annotation!
        if pinAnnotation.photos == nil {
            return []
        } else {
            return pinAnnotation.photos!.allObjects as! [Photo]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: annotation!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation!)
        
        photosCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    func refresh() {
        photosCollectionView.reloadData()
        photosCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return MKPinAnnotationView(annotation: annotation, reuseIdentifier: "detailCell")
    }
    
    // MARK: - PhotoReciever
    
    func photoFetcher(fetcher: Fetcher, didFetchPhotoAtDiskURL: String) {
        refresh()
    }
    
    func photoFetcher(fetcher: Fetcher, didFetchAllPhotosForLocation: CLLocationCoordinate2D) {
        downloadButton.setTitle(newCollectionDetailLabel, forState: .Normal)
        downloadButton.setTitle(newCollectionDetailLabel, forState: .Selected)
        downloadButton.enabled = true
    }
    
    // MARK: - UICollectionViewDataSource
    
    final func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    final func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(detailCollectionViewReuseIdentifier, forIndexPath: indexPath) 
        
        let photo = photos[indexPath.row]
        let diskURL = photo.diskURL!
        
        let image = UIImage(contentsOfFile: diskURL)
        let imageView = UIImageView(frame: cell.bounds)
        imageView.image = image
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = view.bounds.width
        var boxWidth: CGFloat
        
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait:
            fallthrough
        case .PortraitUpsideDown:
            boxWidth = floor(width / 3)
        default:
            boxWidth = floor(width / 5) - 1.0
        }
        
        return CGSize(width: boxWidth, height: boxWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    final func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    final func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    final func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    final func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeZero
    }
}
