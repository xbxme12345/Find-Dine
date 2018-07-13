//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

/**
 send over criteria from user from VC to resultsVC to be used i the search string
 make some rest strings
 ask yan how she do 
 */

import UIKit
import GooglePlacePicker
import GoogleMaps
import Foundation

//main JSON struct
struct geocodingJSON: Codable {
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

//struct to define RestInfo type. Used for storing each resturants info
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
    @IBOutlet weak var searchAgain: UIButton!
    
    //local variables for displaying data from 1st VC
    var travelDistance = String()
    var keyword = String()
    var service = String()
    var devicelatitude = CLLocationDegrees()
    var devicelongitude = CLLocationDegrees()
    var targetlatitude = CLLocationDegrees()
    var targetlongitude = CLLocationDegrees()
    
    //array used to store each restaurant's information
    private var RestList = [RestInfo]()
    
    //var to store random number calculated from RestList.count
    private var randomNum = Int()
    
    //stores random numbers to ensure that no duplicates are used
    private var randomNumList = [Int]()
    
    //stores restaurant coordinates
    private var restPosCoord = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //devicelatitude = (locationManager.location?.coordinate.latitude)!
        //devicelongitude = (locationManager.location?.coordinate.longitude)!
        //travelDistance = "400" //meters
        //keyword = "pizza"
        
        
        print("call geocodingRequest()")
        geocodeRequest()
        
        
        //wait for lat and lng to be set
        while (restPosCoord.longitude == 0.0) {
            print("wait")
        }
        
        //set marker of first restaurant
        print("place 1st marker")
        placeMarker(position: restPosCoord)
    }
    
    func geocodeRequest() {
        /* Prob gonna have to have 2 different urlstrings for keyword/no keyword */
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=42.3360247,-71.0949302&radius=400&type=restaurant&keyword=pizza&key=AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and use geocoding for type
                let restaurantInfo = try JSONDecoder().decode(geocodingJSON.self, from: data)
        
                // append each restaurant info to the array
                for elem in (restaurantInfo.results)! {
                    self.RestList.append(RestInfo(lat: elem.geometry?.location!["lat"]! as! Double, lng:elem.geometry?.location!["lng"]! as! Double, pid: elem.place_id!))
                }
            } catch let jsonError { print(jsonError) }
            
            //calc random number and add to list
            self.randomNum = Int(arc4random_uniform(UInt32(self.RestList.count)))
            self.randomNumList.append(self.randomNum)
            
            // print("Random number: ", self.randomNum)
            // print("num of elems in restlist: ", self.RestList.count)
            
            //display the randomly generated restaurant to the user
            self.setDisplay(pid: self.RestList[self.randomNum].pid)
            //set coordinates of resturant
            self.restPosCoord = CLLocationCoordinate2D(latitude: self.RestList[self.randomNum].lat, longitude: self.RestList[self.randomNum].lng)
        }
        
        task.resume()
    }
    
    //updates the display in resultsViewController to show resturant name, address, rating, price and image
    func setDisplay(pid: String) {
        let placeID = pid
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
    }
    
    //place marker on map
    func placeMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.title = restaurantName.text
        marker.map = mapView
    }
    
    // displays another restaurant from the array to the user.
    // checks to make sure that a duplicate number is not being used.
    // if we reached the end of the RestList then disable the button
    @IBAction func SearchAgain(_ sender: UIButton) {
        mapView.clear()
        if (randomNumList.count < RestList.count) {
            var temp = Int(arc4random_uniform(UInt32(RestList.count)))
            
            repeat {
                temp = Int(arc4random_uniform(UInt32(RestList.count)))
            } while (randomNumList.contains(temp))
            
            randomNum = temp
            randomNumList.append(randomNum)
            setDisplay(pid: RestList[randomNum].pid)
            restPosCoord = CLLocationCoordinate2D(latitude: RestList[randomNum].lat, longitude: RestList[randomNum].lng)
            placeMarker(position: restPosCoord)
            if (randomNumList.count == RestList.count) {
                searchAgain.isEnabled = false;
            }
        }
    }
    
    //convert distance in miles to meters
    func getDistance() -> Double {
        let distance = Double(travelDistance)
        let distanceInMeters = distance! * 1609.344
        return distanceInMeters
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
