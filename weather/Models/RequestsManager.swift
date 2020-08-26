//
//  RequestsManager.swift
//  weather
//
//  Created by Денис on 24.08.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import Foundation
import Alamofire

class RequestManager : NSObject {
    static let dailyForecast: String = "https://api.weatherbit.io/v2.0/forecast/daily"
    static let currentForrecast: String = "https://api.weatherbit.io/v2.0/current"

    
    static func formatParams(dict: [String: Any?], withKey: Bool = true) -> String {
        var params: String = ""
        var separator = "?"
        
        dict.forEach { (key, value) in
            guard value != nil else {
                return
            }
            params += "\(separator)\(key)=\(value!)"
            separator = "&"
        }
        
        if withKey {
            let key: String? = RequestManager.getEnvironmentVar("WEATHER_API_KEY")
            if key != nil {
                params += "\(separator)key=\(key!)"
            }
        }
        
        return params
    }
    static func getEnvironmentVar(_ name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
    }
    
    
    static func makeRequest(url: String, closureBloack: @escaping ([String: AnyObject]) -> ()) {
        AF.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                closureBloack(value as! [String: AnyObject])
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
}
