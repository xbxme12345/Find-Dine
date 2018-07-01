//
//  Geocoding.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/21/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

struct geocoding: Codable {
    let debug_log = [String: String]()
    let html_attributions = [String:String]()
    let logging_info = [String: String]()
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

class Geocoding {
    
    //get Geocode requests
    func geocodeRequest() {
        //new key: AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg
        // Needs to be enabled somehow IT WORK BOIS
        //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670,151.1957&radius=500&types=food&name=cruise&key=AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg
        
        //test strings
        //let urlString = "https://leeg3.github.io/geocoding1.json"
        //let urlString = "https://leeg3.github.io/geocoding2.json"
        //no 3
        //let urlString = "https://leeg3.github.io/geocoding4.json"
        let urlString = "https://leeg3.github.io/geocoding5.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // if error != nil { print(error!.localizedDescription) }
            guard let data = data else { return }
            
            
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                //use [RestaurantInfo].self to get multiples of the same data, use with super query?
                //let restaurantData = try JSONDecoder().decode(RestaurantInfo.self, from: data)
    
                let restaurantInfo = try JSONDecoder().decode(geocoding.self, from: data)
                
                print(restaurantInfo.debug_log)
                print(restaurantInfo.logging_info)
                
                for elem in (restaurantInfo.results)! {
                    print("*********************entry*********************")
                    print(elem.geometry?.location!["lat"]! as! Double)
                    print(elem.geometry?.location!["lng"]! as! Double)
                    //image icon
                    print(elem.icon!)
                    print(elem.id!) // HOW TO ACCESS THE ELEMENTS IN THE ARRAYS
                    //rest info
                    print(elem.name!)
                    print(elem.opening_hours!)
                    print(elem.photos!)
                    //place ID
                    print(elem.place_id!)
                    print(elem.reference!)
                    print(elem.scope!)
                    //i may need dis
                    print(elem.types!)
                    print(elem.vicinity!)
                }
                
                
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
        
        print("*********************entry*********************")
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
    
    func getRestaurants(minPriceLevel: String, maxPricelevel: String, radius: Float, minRating: Int, keyword: String) {
        
        
    }
    
    func geocodeParse() {
        
    }
    
}

//                    print(restaurantInfo.results?[1].geometry?.location!["lat"]! as! Double)
//                    print(restaurantInfo.results?[1].geometry?.location!["lng"]! as! Double)
//                    //image icon
//                    print(restaurantInfo.results![0].icon!)
//                    print(restaurantInfo.results![0].id!) // HOW TO ACCESS THE ELEMENTS IN THE ARRAYS
//                    //rest info
//                    print(restaurantInfo.results![0].name!)
//                    print(restaurantInfo.results![0].opening_hours!)
//                    print(restaurantInfo.results![0].photos!)
//                    //place ID
//                    print(restaurantInfo.results![0].place_id!)
//                    print(restaurantInfo.results![0].reference!)
//                    print(restaurantInfo.results![0].scope!)
//                    //i may need dis
//                    print(restaurantInfo.results![0].types!)
//                    print(restaurantInfo.results![0].vicinity!)
