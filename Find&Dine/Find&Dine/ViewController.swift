//
//  ViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/4/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    //var coordinates: CLLocationCoordinate2D!
    
    
    //Connections to input fields in this ViewController
    @IBOutlet weak var locationInput: UITextField!
    @IBOutlet weak var travelDistanceInput: UITextField!
    @IBOutlet weak var searchKeywordsInput: UITextField!
    @IBOutlet weak var ratingInput: UISlider!
    @IBOutlet weak var reviewServiceInput: UISwitch!
    @IBOutlet weak var minPriceInput: UISegmentedControl!
    @IBOutlet weak var maxPriceInput: UISegmentedControl!
    @IBOutlet weak var ratingOutput: UILabel!
    //@IBOutlet weak var num: UILabel!
    
    //local variables used for extracting values from non text fields
    var rating = Int()
    var service = String()
    var minPrice = "$"
    var maxPrice = "$$"

    //get value of slider and set rating
    @IBAction func ratingChange(_ sender: UISlider) {
        let currentValue = Int(ratingInput.value)
        ratingOutput.text = "\(currentValue)"
        rating = currentValue
    }
    
    //determine service to use
    @IBAction func serviceChange(_ sender: UISwitch) {
        if reviewServiceInput.isOn {
            service = "Yelp"
        }
        else {
            service = "Google"
        }
    }
    
    //get minPrice
    @IBAction func minPriceChange(_ sender: UISegmentedControl) {
        switch minPriceInput.selectedSegmentIndex {
        case 0:
            minPrice = "$"
        case 1:
            minPrice = "$$"
        case 2:
            minPrice = "$$$"
        case 3:
            minPrice = "$$$$"
        default:
            break
        }
    }
    
    //get maxPrice
    @IBAction func maxPriceChange(_ sender: UISegmentedControl) {
        switch maxPriceInput.selectedSegmentIndex {
        case 0:
            maxPrice = "$"
        case 1:
            maxPrice = "$$"
        case 2:
            maxPrice = "$$$"
        case 3:
            maxPrice = "$$$$"
        default:
            break
        }
    }
    
    //assigning variables to variables in resultsVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let resultsViewController = segue.destination as! resultsViewController
        resultsViewController.location = locationInput.text!
        resultsViewController.travelDistance = travelDistanceInput.text!
        resultsViewController.keyword = searchKeywordsInput.text!
        resultsViewController.minRating = rating
        resultsViewController.service = service
        resultsViewController.minPrice = minPrice
        resultsViewController.maxPrice = maxPrice
        //resultsViewController.coordinates = coordinates
        
    }
    
    /*// send data to results VC
    @IBAction func generate(_ sender: Any) {
        if locationInput.text != "" && travelDistanceInput.text != "" && searchKeywordsInput.text != "" {
            performSegue(withIdentifier: "toResults", sender: self)
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        }
        
        /*num.text = String(numVal)
        if numVal > 0 {
            locationInput.text = location
            travelDistanceInput.text = travelDistance
            searchKeywordsInput.text = keywords
        }
        */
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    //self.locationInput.text = place.name
                    self.locationInput.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
                    //self.coordinates = place.coordinate
                }
            }
        })
    }
    
}

