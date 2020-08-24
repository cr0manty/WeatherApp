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
import SVProgressHUD

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
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    let realm = try! Realm()
    var locationManager: CLLocationManager!
    var weatherList: Results<Weather>!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date: Date = Date()
        self.timeLabel.text = date.getFormattedDate(format: "d E, h:mm a")
        
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
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                
                if placemark.locality != nil && !placemark.locality!.isEmpty {
                    self.locationLabel.text = placemark.locality!
                    
                    let predicate = NSPredicate(format: "date >=  %@ and city == %@", Date().daysdelta(4)! as NSDate, placemark.locality!)
                    self.weatherList = self.realm.objects(Weather.self).filter(predicate)
                    self.fetchCurrentWeather(lat: userLocation.coordinate.latitude, lon: userLocation.coordinate.longitude)
                }
            }
        }
        
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double) {
        if self.weatherList.count < 4 {
//            self.view.isUserInteractionEnabled = false
//            SVProgressHUD.show()
            
            let params: String = RequestManager.formatParams(dict: ["lat" : lat, "lon": lon, "days": 16])
            RequestManager.makeRequest(params: params, closureBloack: { (response) in
                for data in response["data"] as! [AnyObject] {
                    let weather: Weather = Weather.fromJson(json: data as! [String: Any], city: response["city_name"] as! String)
                    try! self.realm.write {
                        self.realm.add(weather)
                    }
                }
                
//                self.view.isUserInteractionEnabled = true
//                SVProgressHUD.dismiss()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
}

