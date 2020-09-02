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
    case Thunderstorm, Drizzle, Rain, Snow, Mist, Clouds, ClearDay,
    ClearNight, PartialCloudsDay, PartialCloudsNight, Unknown
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
    @objc dynamic var createAt: Date?
    var minTemp = RealmOptional<Double>()
    var maxTemp = RealmOptional<Double>()
    
    private static func fromJson(json: [String: Any], city: String) -> Weather {
        let weather = Weather()
        print(json)
        
        weather.temp = json["temp"] as! Double
        weather.clouds = json["clouds"] as! Double
        weather.date = Weather.dateFormat(json["datetime"] as? String)
        weather.precip = json["precip"] as! Double
        weather.city = city
        weather.createAt = Date()
        
        return weather
    }
    
    static func forecastFromJson(json: [String: Any], city: String) -> Weather {
        let weather = self.fromJson(json: json, city: city)
        
        weather.minTemp = RealmOptional<Double>(json["min_temp"] as? Double)
        weather.maxTemp = RealmOptional<Double>(json["max_temp"] as? Double)
        weather.sunset =  Date(timeIntervalSince1970: json["sunset_ts"] as! Double)
        weather.sunrise = Date(timeIntervalSince1970: json["sunrise_ts"] as! Double)
        
        do {
            weather.type = try (json["weather"] as! [String: Any])["code"] as! Int
        } catch {
            let typeStr = (json["weather"] as! [String: Any])["code"] as! String
            weather.type = Int(typeStr)!
        }
        
        return weather
    }
    
    static func currentFromJson(json: [String: Any], city: String) -> Weather {
        let weather = self.fromJson(json: json, city: city)
        
        weather.sunrise = self.parseTime(time: json["sunrise"] as! String)
        weather.sunset = self.parseTime(time: json["sunset"] as! String)
        
        do {
            weather.type = try (json["weather"] as! [String: Any])["code"] as! Int
        } catch {
            let typeStr = (json["weather"] as! [String: Any])["code"] as! String
            weather.type = Int(typeStr)!
        }
        
        return weather
    }
    
    static func parseTime(time: String, date: Date = Date()) -> Date {
        let timeArr: [Int] = time.split { $0 == ":" } .map { (x) -> Int in return Int(String(x))! }
        return Calendar.current.date(bySettingHour: timeArr[0], minute: timeArr[1], second: 0, of: date)!
    }
    
    static func dateFormat(_ value: String?) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: value!)
    }
    
    var weatherType: WeatherType {
        let now: Date = Date()
        
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
            return self.sunset! < now && now < self.sunrise! ? WeatherType.ClearNight : WeatherType.ClearDay
        case 801...803:
            return self.sunset! < now && now < self.sunrise! ? WeatherType.PartialCloudsNight : WeatherType.PartialCloudsDay
        case 804...899:
            return WeatherType.Clouds
        default:
            return WeatherType.Unknown
        }
    }
    
    private func doubleToIntString(_ value: Double) -> String{
        let intTemp: Int = Int(exactly:(value).rounded())!
        return String(intTemp)
    }
    
    var tempString: String {
        return self.doubleToIntString(self.temp)
    }
    
    var minTempString: String {
        return self.doubleToIntString(self.minTemp.value!)
    }
    
    var maxTempString: String {
        return self.doubleToIntString(self.maxTemp.value!)
    }
    
    var dayTemp: String {
        return "\(self.maxTempString)° / \(self.minTempString)°"
    }
}
