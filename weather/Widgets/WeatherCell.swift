//
//  WeatherCell.swift
//  weather
//
//  Created by Денис on 27.08.2020.
//  Copyright © 2020 cr0manty. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    @IBOutlet weak var dayLable: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
