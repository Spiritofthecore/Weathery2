//
//  WeatherCell.swift
//  Weathery
//
//  Created by Macbook on 1/23/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit

protocol EditWeatherCell {
    func DeleteCell()
}

class WeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var TemperatureLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var WeatherImage: UIImageView!
}
