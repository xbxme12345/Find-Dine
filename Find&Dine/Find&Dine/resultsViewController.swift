//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

/**
 TODO:
 retrieve coordinates for El Pelon so marker can be dropped automatically,
 - test with 1-2 other restaurants
 retrieve placeID from restaurants in area
 
 be able to calculate distance away from user?
 
 find out how much we need to +/- from a current location to end of search radius
 
 */
 

import UIKit
import GooglePlacePicker
import GoogleMaps
import Foundation

class resultsViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    
    //init map view
    @IBOutlet weak var mapView: GMSMapView!
    
    //init display
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var placeAddr: UILabel!
    @IBOutlet weak var placeRating: UILabel!
    @IBOutlet weak var placePrice: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    
    
    //local variables for displaying data from 1st VC 
    //var location = String()
    var travelDistance = String()
    var keyword = String()
    var service = String()
    var currentlatitude = CLLocationDegrees()
    var currentlongitude = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //get restaurant info from Google 
        //create instance of Geocoding and make it retrieve all info?
        
        print("Before geocoding request")
        let p1 = Geocoding()
        
        p1.geocodeRequest()

        //output found location info *currently hardcoded
        getPlaceInfo()
        
        
    
    
    }
    
    //convert distance in miles to meters
    func getDistance() -> Double {
        let distance = Double(travelDistance)
        let distanceInMeters = distance! * 1609.344
        //distanceOutput.text = String(distanceInMeters)
        return distanceInMeters
    }
    
    func getPlaceInfo() {
        // El Pelon
        let placeID = "ChIJ1SGgo_V544kRmGe2qAAC1x0"
        let placesClient = GMSPlacesClient()
        
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            self.restaurantName.text = place.name
            self.placeAddr.text = place.formattedAddress
            self.placeRating.text = String(place.rating)
            self.placePrice.text = self.text(for: place.priceLevel)
            self.loadFirstPhotoForPlace(placeID: place.placeID)
            
        })
        
        let position = CLLocationCoordinate2D(latitude: 42.3418371, longitude: -71.0976021)
        let marker = GMSMarker(position: position)
        marker.title = restaurantName.text
        marker.map = mapView
        
        
    }
        
    // Return the appropriate text string for the specified |GMSPlacesPriceLevel|.
    func text(for priceLevel: GMSPlacesPriceLevel) -> String {
        switch priceLevel {
            case .free: return NSLocalizedString("Free", comment: "Free")
            case .cheap: return NSLocalizedString("$", comment: "$")
            case .medium: return NSLocalizedString("$$", comment: "$$")
            case .high: return NSLocalizedString("$$$", comment: "$$$")
            case .expensive: return NSLocalizedString("$$$$", comment: "$$$$")
            case .unknown: return NSLocalizedString("Unknown", comment: "Unknown")
            }
    }
        
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
        
    private func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.restaurantImage.image = photo;
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension resultsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }

        locationManager.startUpdatingLocation()
    
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}


/**
 func circle() {
 currentlatitude = (locationManager.location?.coordinate.latitude)!
 currentlongitude = (locationManager.location?.coordinate.longitude)!
 
 let circleCenter = CLLocationCoordinate2D(latitude: currentlatitude, longitude: currentlongitude)
 
 let circ = GMSCircle(position: circleCenter, radius: getDistance())
 circ.map = mapView
 }
 */
