//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

/**
 TODO:
 get places within x radius of user and display on map
 
 */
 

import UIKit
import GooglePlacePicker
import GoogleMaps

class resultsViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    
    //init map view
    @IBOutlet weak var mapView: GMSMapView!
    
    //init display
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var placeAddr: UILabel!
    @IBOutlet weak var placeRating: UILabel!
    @IBOutlet weak var placePrice: UILabel!
    
    
    //local variables for displaying data from 1st VC 
    var location = String()
    var travelDistance = String()
    var keyword = String()
    var minRating = Int()
    var service = String()
    var minPrice = String()
    var maxPrice = String()
    var currentlatitude = CLLocationDegrees()
    var currentlongitude = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //draw circle with radius of Travel distance 
        circle()
        
        getPlaceInfo()
    }
    
    func circle() {
        currentlatitude = (locationManager.location?.coordinate.latitude)!
        currentlongitude = (locationManager.location?.coordinate.longitude)!
        
        let circleCenter = CLLocationCoordinate2D(latitude: currentlatitude, longitude: currentlongitude)
        
        let circ = GMSCircle(position: circleCenter, radius: getDistance())
        circ.map = mapView
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
            //self.placePrice.text = String(place.priceLevel)
            
            
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
 // connections to labels in this VC
 @IBOutlet weak var locationOutput: UILabel!
 @IBOutlet weak var travelDistanceOutput: UILabel!
 @IBOutlet weak var keywordOutput: UILabel!
 @IBOutlet weak var minRatingOutput: UILabel!
 @IBOutlet weak var serviceOutput: UILabel!
 @IBOutlet weak var minPriceOutput: UILabel!
 @IBOutlet weak var maxPriceOutput: UILabel!
 
 
 //set text
 locationOutput.text = location
 travelDistanceOutput.text = travelDistance
 keywordOutput.text = keyword
 minRatingOutput.text = String(minRating)
 serviceOutput.text = service
 minPriceOutput.text = minPrice
 maxPriceOutput.text = maxPrice
 
 /**/
 */
