//
//  Night.swift
//  weather
//
//  Created by Денис on 01.09.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import UIKit

class MoonWeather: SunnyWeather {
    override var firstCircleColor: UIColor {
        return UIColor(red: 233/255, green: 231/255, blue: 244/255, alpha: 1)
    }
    override var centerCircleColor: UIColor {
        return UIColor(red: 175/255, green: 168/255, blue: 212/255, alpha: 1)
    }
    override var lastCircleColor: UIColor {
        return UIColor(red: 125/255, green: 113/255, blue: 187/255, alpha: 1)
    }
    override var pulseColor: CGColor {
        CGColor(srgbRed: 82/255, green: 82/255, blue: 152/255, alpha: 1)
    }
    override var shadowColor: UIColor {
        return UIColor(red: 71/255, green: 57/255, blue: 119/255, alpha: 1)
    }
    
    override func initAdditionalElements(_ rect: CGRect) {
        self.addMoonCrater()
        self.addStars()
    }
    
    func addStars() {
        let starAmount: Int = Int.random(in: 5...20)
        
        for _ in 0...starAmount {
            let x: CGFloat = self.frame.size.width * CGFloat((arc4random_uniform(100) / 100))
            let y: CGFloat = self.frame.size.height * CGFloat((arc4random_uniform(100) / 100))
            
            let star: UIView! = UIView(frame: CGRect(x: x, y: y, width: 10, height: 10))
            star.backgroundColor = UIColor(red: 219/255, green: 217/255, blue: 231/255, alpha: 1)
            star.layer.cornerRadius = 5
            self.insertSubview(star, belowSubview: self.lastCircle)
        }
    }
    
    func addMoonCrater() {
        for _ in 0...4 {
            let arc: Double = Double.random(in: 0...50)
            let x: CGFloat = CGFloat(25 * cos(arc))
            let y: CGFloat = CGFloat(25 * sin(arc))
            
            let moonCrater: UIView! = UIView(frame: CGRect(x: self.centerCircle.center.x + x, y: self.centerCircle.center.y + y, width: 10, height: 10))
            moonCrater.backgroundColor = UIColor(red: 219/255, green: 217/255, blue: 231/255, alpha: 1)
            moonCrater.layer.cornerRadius = 5
            self.insertSubview(moonCrater, aboveSubview: self)
            
        }
    }
}
