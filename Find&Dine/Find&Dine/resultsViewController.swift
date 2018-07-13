//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

/**
 TODO:
 figure out how to get info from geocoding class over to here
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

struct geocoding: Codable {
    let html_attributions = [String:String]()
    let results: [infoResult]?
}

//supplementary structs
struct infoResult: Codable {
    let geometry: loc?
    let icon: String?
    let id: String?
    let name: String?
    let opening_hours: hours?
    let photos: [image]?
    let place_id: String?
    let price_level: Int?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let vicinity: String?
}
struct lines: Codable {
    let line: [String]?
}
struct log_info: Codable {
    let experiment_id: [String]?
    let query_geographic_location: String?
}
struct loc: Codable {
    let location: [String: Double]?
}
struct location: Codable {
    let lat: Double
    let lng: Double
}
struct hours: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}
struct image: Codable {
    let height: Int?
    let html_attributions: [String]?
    let photo_reference: String?
    let width: Int?
}

struct RestInfo {
    let lat: Double
    let lng: Double
    let pid: String
}

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
    
    //API info
    var RestArr = [RestInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //get restaurant info from Google 
        //create instance of Geocoding and make it retrieve all info?
        
        print("Before geocoding request")
        
//        currentlatitude = (locationManager.location?.coordinate.latitude)!
//        currentlongitude = (locationManager.location?.coordinate.longitude)!
//        travelDistance = "400"
//        keyword = "pizza"
        
        // geocodeRequest(lat: String(currentlatitude), lng: String(currentlongitude), radius: travelDistance, keyword: keyword.self)
        geocodeRequest()
        
        //output found location info *currently hardcoded*
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
        
        //randomly pick an element in the list
        let num = Int.random(in: 0...RestArr.length)
        
        print("Random num: ", num)
        
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
    
    // func geocodeRequest(lat: String, lng: String, radius: String, keyword: String) {
    func geocodeRequest() {
        
        //new key: AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg
        //        The following example is a search request for places of type 'restaurant' within a 1500m radius of a point in Sydney, Australia, containing the word 'cruise':
        //        https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670,151.1957&radius=500&types=food&name=cruise&key=AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg
        
        /* Prob gonna have to have 2 different urlstrings for keyword/no keyword */
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=42.3360247,-71.0949302&radius=400&type=restaurant&keyword=pizza&key=AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // if error != nil { print(error!.localizedDescription) }
            guard let data = data else { return }
            
            
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and use geocoding for type
                let restaurantInfo = try JSONDecoder().decode(geocoding.self, from: data)
                
                for elem in (restaurantInfo.results)! {
                    //print("*********************entry*********************")
                    //print(elem.geometry?.location!["lat"]! as! Double)
                    //print(elem.geometry?.location!["lng"]! as! Double)
                    //print(elem.place_id!)
                    self.RestArr.append(RestInfo(lat: elem.geometry?.location!["lat"]! as! Double, lng: elem.geometry?.location!["lng"]! as! Double, pid: elem.place_id!))
                }
                
            } catch let jsonError { print(jsonError) }
            
                    print("Before output")
                    for elem in self.RestArr {
                        print("****************************")
                        print("lat: ", elem.lat)
                        print("lng: ", elem.lng)
                        print("pid: ", elem.pid)
                    }
            
            }.resume()
        
        
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
