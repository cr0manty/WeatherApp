//
//  Weather.swift
//  weather
//
//  Created by Денис on 24.08.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import Foundation
import RealmSwift

enum WeatherType {
    case Thunderstorm, Drizzle, Rain, Snow, Mist, Clouds, Clear, Unknown
}

class Weather : Object {
    @objc dynamic var temp = 0.0
    @objc dynamic var sunset: Date?
    @objc dynamic var sunrise: Date?
    @objc dynamic var clouds = 0.0
    @objc dynamic var type = 0
    @objc dynamic var date: Date?
    @objc dynamic var precip = 0.0
    @objc dynamic var city = ""
    
    static func fromJson(json: [String: Any], city: String = "") -> Weather {
        let weather = Weather()
        
        weather.temp = json["temp"] as! Double
        weather.sunset = Date(timeIntervalSince1970: json["sunset_ts"] as! Double)
        weather.sunrise = Date(timeIntervalSince1970: json["sunrise_ts"] as! Double)
        weather.clouds = json["clouds"] as! Double
        weather.type = (json["weather"] as! [String: Any])["code"] as! Int
        weather.date = Weather.dateFormat(json["datetime"] as? String)
        weather.precip = json["precip"] as! Double
        weather.city = city
        
        return weather
    }
    
    static func dateFormat(_ value: String?) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.date(from: value!)
    }
    
    var weatherType: WeatherType {
        switch type {
        case 200...299:
            return WeatherType.Thunderstorm
        case 300...399:
            return WeatherType.Drizzle
        case 500...599:
            return WeatherType.Rain
        case 600...699:
            return WeatherType.Snow
        case 700...799:
            return WeatherType.Mist
        case 800:
            return WeatherType.Clear
        case 801...899:
            return WeatherType.Clouds
        default:
            return WeatherType.Unknown
        }
    }
}
