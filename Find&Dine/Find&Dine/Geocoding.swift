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

//struct geocoding: Codable {
//    let html_attributions = [String:String]()
//    let results: [infoResult]?
//}
//
////supplementary structs
//struct infoResult: Codable {
//    let geometry: loc?
//    let icon: String?
//    let id: String?
//    let name: String?
//    let opening_hours: hours?
//    let photos: [image]?
//    let place_id: String?
//    let price_level: Int?
//    let rating: Double?
//    let reference: String?
//    let scope: String?
//    let types: [String]?
//    let vicinity: String?
//}
//struct lines: Codable {
//    let line: [String]?
//}
//struct log_info: Codable {
//    let experiment_id: [String]?
//    let query_geographic_location: String?
//}
//struct loc: Codable {
//    let location: [String: Double]?
//}
//struct location: Codable {
//    let lat: Double
//    let lng: Double
//}
//struct hours: Codable {
//    let open_now: Bool?
//    let weekday_text: [String]?
//}
//struct image: Codable {
//    let height: Int?
//    let html_attributions: [String]?
//    let photo_reference: String?
//    let width: Int?
//}
//
//struct RestInfo {
//    let lat: Double
//    let lng: Double
//    let pid: String
//}

class Geocoding {
    
    //get Geocode requests
    // func geocodeRequest(lat: String, lng: String, radius: String, keyword: String) {
    func geocodeRequest() {
        
    var RestArr = [RestInfo]()
        
    //new key: AIzaSyDtbc_paodfWo1KRW0fGQ1dB--g8RyG-Kg
    // Needs to be enabled somehow IT WORK BOIS
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
            RestArr.append(RestInfo(lat: elem.geometry?.location!["lat"]! as! Double, lng: elem.geometry?.location!["lng"]! as! Double, pid: elem.place_id!))
        }
            
    } catch let jsonError { print(jsonError) }
        
//        print("Before output")
//        for elem in RestArr {
//            print("****************************")
//            print("lat: ", elem.lat)
//            print("lng: ", elem.lng)
//            print("pid: ", elem.pid)
//        }
        
    }.resume()
        
        
    }
    
    func getRestaurants(minPriceLevel: String, maxPricelevel: String, radius: Float, minRating: Int, keyword: String) {
        
        
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
