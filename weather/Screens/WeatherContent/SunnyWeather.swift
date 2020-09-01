//
//  WeatherAnimation.swift
//  weather
//
//  Created by Денис on 31.08.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import UIKit

class SunnyWeather: UIView {
    var timer: Timer?
    
    @IBOutlet var weatherCenter: UIView!
    @IBOutlet var lastCircle: UIView!
    @IBOutlet var centerCircle: UIView!
    
    var firstCircleColor: UIColor {
        return UIColor(red: 1, green: 231/255, blue: 89/255, alpha: 1)
    }
    var centerCircleColor: UIColor {
        return UIColor(red: 233/255, green: 136/255, blue: 113/255, alpha: 1)
    }
    var lastCircleColor: UIColor {
        return UIColor(red: 214/255, green: 91/255, blue: 114/255, alpha: 1)
    }
    var pulseColor: CGColor {
        CGColor(srgbRed: 194/255, green: 63/255, blue: 103/255, alpha: 1)
    }
    var shadowColor: UIColor {
        return UIColor(red: 149/255, green: 65/255, blue: 105/255, alpha: 1)
    }


    override func draw(_ rect: CGRect) {
        self.initWeather()
        self.initAdditionalElements(rect)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
        target: self,
        selector: #selector(addPulse),
        userInfo: nil,
        repeats: true)
    }
    
    func initAdditionalElements(_ rect: CGRect) {
    }
    
    func initWeather() {
        self.weatherCenter = UIView(frame: CGRect(x:137, y: 132, width: 100, height: 100))
        self.weatherCenter.backgroundColor = self.firstCircleColor
        self.weatherCenter.layer.cornerRadius = 50
        
        self.centerCircle = UIView(frame: CGRect(x:122, y: 117, width: 130, height: 130))
        self.centerCircle.backgroundColor = self.centerCircleColor
        self.centerCircle.layer.cornerRadius = 60
        
        self.lastCircle = UIView(frame: CGRect(x:107, y: 102, width: 160, height: 160))
        self.lastCircle.backgroundColor = self.lastCircleColor
        self.lastCircle.layer.cornerRadius = 80
        
        self.lastCircle.layer.shadowOpacity = 0.8
        self.lastCircle.layer.shadowOffset = .zero
        self.lastCircle.layer.shadowRadius = 75
        self.lastCircle.layer.shadowColor = self.shadowColor.cgColor
        
        self.insertSubview(self.lastCircle, aboveSubview: self)
        self.insertSubview(self.centerCircle, aboveSubview: self)
        self.insertSubview(self.weatherCenter, aboveSubview: self)
    }
    
    @objc func addPulse(){
        let pulse = Pulse(numberOfPulses: 1, radius: 125, position: self.weatherCenter.center)
        pulse.animationDuration = 5
        pulse.backgroundColor = self.pulseColor
        
        self.layer.insertSublayer(pulse, above: self.centerCircle.layer)
    }
    
}
