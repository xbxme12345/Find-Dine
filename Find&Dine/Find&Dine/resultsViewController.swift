//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import UIKit
import GooglePlacePicker
import GoogleMaps

class resultsViewController: UIViewController {
    
    // connections to labels in this VC
    @IBOutlet weak var locationOutput: UILabel!
    @IBOutlet weak var travelDistanceOutput: UILabel!
    @IBOutlet weak var keywordOutput: UILabel!
    @IBOutlet weak var minRatingOutput: UILabel!
    @IBOutlet weak var serviceOutput: UILabel!
    @IBOutlet weak var minPriceOutput: UILabel!
    @IBOutlet weak var maxPriceOutput: UILabel!
    //@IBOutlet weak var latitude: UILabel!
    //@IBOutlet weak var longitude: UILabel!
    
    private let locationManager = CLLocationManager()
    
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
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set text 
        locationOutput.text = location
        travelDistanceOutput.text = travelDistance
        keywordOutput.text = keyword
        minRatingOutput.text = String(minRating) 
        serviceOutput.text = service
        minPriceOutput.text = minPrice
        maxPriceOutput.text = maxPrice
        
        //currentlatitude = (locationManager.location?.coordinate.latitude)!
        //currentlongitude = (locationManager.location?.coordinate.longitude)!
        
        //latitude.text = String(currentlatitude)
        //longitude.text = String(currentlongitude)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        circle() 
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func circle()
    {
        let circleCenter = CLLocationCoordinate2D(latitude: 42.3366871, longitude: -71.0979504)
        let circ = GMSCircle(position: circleCenter, radius: 800)
        circ.map = mapView
    }

}
// MARK: - CLLocationManagerDelegate
//1
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
