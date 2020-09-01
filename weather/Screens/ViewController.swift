//
//  ViewController.swift
//  weather
//
//  Created by Денис on 24.08.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    var tomorrow: Date! {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func daysdelta(_ days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func hoursDelta(_ hours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    let maxWeatherListCount: Int = 3
    var realm: Realm!
    var locationManager: CLLocationManager!
    var weatherList: Results<Weather>!
    var currentWeather: Results<Weather>!
    var timer: Timer?
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var animatiomView: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = Realm.Configuration(schemaVersion: 5)
        self.realm = try! Realm(configuration: configuration)

        let date: Date = Date()
        self.timeLabel.text = date.getFormattedDate(format: "d E, ha").uppercased()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                
                if placemark.locality != nil && !placemark.locality!.isEmpty {
                    self.locationLabel.text = placemark.locality!.uppercased()
                    self.fetchCurrentData(placemark.locality!)
                    self.fetchWeatherList(placemark.locality!)
                    
                    self.fetchCurrentWeather(lat: userLocation.coordinate.latitude, lon: userLocation.coordinate.longitude)
                }
            }
        }
    }
    
    func fetchCurrentData(_ city: String) {
        let currentPredicate = NSPredicate(format: "createAt <= %@ and city == %@", Date().hoursDelta(6)! as NSDate, city)
        self.currentWeather = self.realm.objects(Weather.self).filter(currentPredicate).sorted(byKeyPath: "createAt")
        
        guard self.currentWeather.count != 0 else {
            return
        }
        self.tempLabel.text = self.currentWeather[0].tempString
        self.view.setNeedsDisplay()
    }
    
    func fetchWeatherList(_ city: String) {
        let predicate = NSPredicate(format: "date >  %@ and city == %@", Date() as NSDate, city)
        self.weatherList = self.realm.objects(Weather.self).filter(predicate).sorted(byKeyPath: "date").distinct(by: ["date"])
        self.weatherTableView.reloadData()
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double) {
        var paramsDict: [String: Any] = ["lat" : lat, "lon": lon]
        
        if self.weatherList.count < self.maxWeatherListCount {
            let params: String = RequestManager.formatParams(dict: paramsDict)
            RequestManager.makeRequest(url: RequestManager.dailyForecast + params, closureBloack: { (response) in
                let city = response["city_name"] as! String
                
                for data in response["data"] as! [AnyObject] {
                    let weather: Weather = Weather.forecastFromJson(json: data as! [String: Any], city: city)
                    try! self.realm.write {
                        self.realm.add(weather)
                    }
                }
                self.fetchWeatherList(city)
            })
        }
        
        if self.currentWeather.count == 0 {
            paramsDict["days"] = 16
            let params: String = RequestManager.formatParams(dict: paramsDict)
            
            RequestManager.makeRequest(url: RequestManager.currentForrecast + params, closureBloack: { (response) in
                var city: String?
                
                for data in response["data"] as! [AnyObject] {
                    city = data["city_name"] as? String
                    let weather: Weather = Weather.currentFromJson(json: data as! [String: Any], city: city!)
                    try! self.realm.write {
                        self.realm.add(weather)
                    }
                }
                self.fetchCurrentData(city!)
            })
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as! WeatherCell
        cell.dayLable.text = self.weatherList[indexPath.row].date!.getFormattedDate(format: "E").uppercased()
        cell.weatherLabel.text = weatherList[indexPath.row].dayTemp
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherList?.count ?? 0 > self.maxWeatherListCount ? self.maxWeatherListCount : self.weatherList?.count ?? 0
    }
}

