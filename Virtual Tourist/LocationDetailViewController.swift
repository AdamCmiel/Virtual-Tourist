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

class LocationDetailViewController: UIViewController, PhotoReciever, MKMapViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func collectionButtonPressed(sender: AnyObject) {
        let pin = annotation!
        let photosToRemove = pin.photos!.copy() as! NSSet
        pin.removePhotos(pin.photos!)
        
        let context = AppDelegate.managedContext
        
        photosToRemove.forEach {
            context.deleteObject($0 as! Photo)
            saveCoreData()
        }
        
        refresh()
        
        pin.incrementPage()
        pin.getPhotosFromFlickr()
        
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
        refresh()
        
        if annotation!.hasFetchedAllPhotos {
            resetButton()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(downloadButton)
    }

    func refresh() {
        photosCollectionView.reloadData()
        photosCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func resetButton() {
        downloadButton.setTitle(newCollectionDetailLabel, forState: .Normal)
        downloadButton.setTitle(newCollectionDetailLabel, forState: .Selected)
        downloadButton.enabled = true
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
        resetButton()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoToRemove = photos[indexPath.row]
        let context = AppDelegate.managedContext
        
        context.deleteObject(photoToRemove)
        let pin = photoToRemove.pin
        pin?.removePhotos(NSSet(object: photoToRemove))
        
        saveCoreData()
        refresh()
    }
    
    // MARK: - UICollectionViewDataSource
    
    final func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    final func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(detailCollectionViewReuseIdentifier, forIndexPath: indexPath)
        
        let photo = photos[indexPath.row]
        let diskURL = photo.diskURL!
        
        let image = PhotoFileManager.sharedManager.fetchFileFromDisc(diskURL)
        let imageView = UIImageView(frame: cell.bounds)
        imageView.image = image
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let thirdWidth = screenWidth * 0.333 - 1.0
        return CGSize(width: thirdWidth, height: thirdWidth)
    }
}
