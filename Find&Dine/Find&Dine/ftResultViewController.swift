//
//  ftResultViewController.swift
//  Find&Dine
//
//  Created by Yan Wen Huang on 6/17/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift
import SQLite3

struct Food_Truck: Decodable{
    let meal: String?
    let location: String?
    let dayOfWeek: String?
    let foodTruck: String?
    
    init(json: [String:Any]) {
        meal = json["meal"] as? String ?? ""
        location = json["location"] as? String ?? ""
        dayOfWeek = json["dayOfWeek"] as? String ?? ""
        foodTruck = json["foodTruck"] as? String ?? ""
    }
}

class ftResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewFoodTruck: UITableView!
    
    // local variables for receiving data from 1st VC
    var locationFlag = Int()
    var location = String()
    var travelDistance = String()
    
    var db: OpaquePointer?
    var foodTruckList = [foodTruck]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodTruckList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        let foodTruck: foodTruck
        foodTruck = foodTruckList[indexPath.row]
        cell.textLabel?.text = foodTruck.foodTruckName
        return cell
    }
    
    func readData() {
        //Empty the list of food truck
        foodTruckList.removeAll()
        
        //This is the select query
        let queryString = "SELECT * FROM foodtruck;"
        
        //Statement pointer
        var stmt: OpaquePointer?
        
        //Preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert: \(errmsg)")
            return
        }
        
        //Traversing through the records
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let meal = String(cString: sqlite3_column_text(stmt, 1))
            let location = String(cString: sqlite3_column_text(stmt, 2))
            let dayOfWeek = String(cString: sqlite3_column_text(stmt, 3))
            let foodTruckName = String(cString: sqlite3_column_text(stmt, 4))
            
            //Adding values to list
            foodTruckList.append(foodTruck(id: Int(id), meal: String(describing: meal), location: String(describing: location), dayOfWeek: String(describing: dayOfWeek), foodTruckName: String(describing: foodTruckName)))
        }
        self.tableViewFoodTruck.reloadData()
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let ftData = object["ftData"] as? [[String: AnyObject]] else { return }
        
        for FoodTruck in ftData {
            guard let meal = FoodTruck["meal"] as? String,
                let dayOfWeek = FoodTruck["DayOfWeek"] as? String,
                let ftName = FoodTruck["FoodTruck"] as? String else { break }
            _ = ftName + " for " + meal + " on " + dayOfWeek
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let path = Bundle.main.path(forResource: "foodtruck", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print(json)
            
            guard let array = json as? [Any] else {return}
            
            for foodTruckName in array {
                guard let foodTruck = foodTruckName as? [String: Any] else {return}
                guard let ftMeal = foodTruck["Meal"] as? String else {print("not a meal string"); return}
                guard let ftLocation = foodTruck["Location"] as? String else {print("not a location string");return}
                guard let ftDayOfWeek = foodTruck["DayOfWeek"] as? String else {print("not a day of week string"); return}
                guard let ftName = foodTruck["FoodTruck"] as? String else {print("not a name string");return}
                
                print(ftMeal)
                print(ftLocation)
                print(ftDayOfWeek)
                print(ftName)
                print(" ")
            }
        } catch {
            print(error)
        }
        
        
        
        /*
        let jsonUrlString = "https://gist.githubusercontent.com/xbxme12345/81cfca65048a4a1a66baef09b3977864/raw/1ce568174db67b037126fce345fd6d1cd58ed361/json"
        guard let url = URL(string: jsonUrlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            //let dataAsString = String(data: data, encoding: .utf8)
            
            do {
                let foodtruck = try JSONDecoder().decode(Food_Truck.self, from: data)
                print(foodtruck.location)
                /*guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {return}
                
                let foodtruck = Food_Truck(json: json)
                print(foodtruck.meal)*/
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }.resume()*/
        
        //let myFoodTruck = Food_Truck(meal: "Lunch", location: "Boston, MA", dayOfWeek: "Monday", foodTruck: "Bon Me")
        //print(myFoodTruck)
        /*
        let url = "https://gist.githubusercontent.com/xbxme12345/ef39ccba761091e6d6cff365be5968fc/raw/7ab6645d4b8049975b67e29883eb0bb5176575de/foodtruck.json"
        let urlObject = URL(string: url)
        
        URLSession.shared.dataTask(with: urlObject!) {(data, response, error) in
            do {
                let FoodTruck = try JSONDecoder().decode([fTruck].self, from: data!)
                for fTruck in FoodTruck {
                    print(fTruck.foodTruck)
                }
            } catch {
                print("We got an error \(error)")
            }
        }.resume()*/
        
        
        /*
        //Reads in the data file of foodtruck.json
        let url = Bundle.main.url(forResource: "foodtruck", withExtension: "json")
        let data = NSData(contentsOf: url!)
        
        //Parsing the data
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary)
            }
        } catch {
            //Handle Error
        }*/
        
        /*
        //The Food Truck database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("FoodTruck.sqlite")
        
        //Opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //Creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS FoodTruck (id INTEGER PRIMARY KEY AUTOINCREMENT, meal TEXT, location TEXT, dayOfWeek TEXT, foodTruckName TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readData()*/
    }
}

