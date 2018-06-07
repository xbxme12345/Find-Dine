//
//  resultsViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/6/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import UIKit

class resultsViewController: UIViewController {
    
    // connections to labels in this VC
    @IBOutlet weak var locationOutput: UILabel!
    @IBOutlet weak var travelDistanceOutput: UILabel!
    @IBOutlet weak var keywordOutput: UILabel!
    @IBOutlet weak var minRatingOutput: UILabel!
    @IBOutlet weak var serviceOutput: UILabel!
    @IBOutlet weak var minPriceOutput: UILabel!
    @IBOutlet weak var maxPriceOutput: UILabel!
    
    //local variables for displaying data from 1st VC 
    var location = String()
    var travelDistance = String()
    var keyword = String()
    var minRating = Int()
    var service = String()
    var minPrice = String()
    var maxPrice = String()
    
    
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
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }
    
    //trying to send data back to first screeen to "remember" values entered
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let firstVC = segue.destination as! ViewController
        firstVC.location = location
        firstVC.travelDistance = travelDistance
        firstVC.keywords = keyword
    }
    

}
