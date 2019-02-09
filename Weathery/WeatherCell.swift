//
//  WeatherCell.swift
//  Weathery
//
//  Created by Macbook on 1/23/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit

protocol EditWeatherCell {
    func DeleteTheCell(indexPath: IndexPath)
}

class WeatherCell: UICollectionViewCell {
    
    var delegate: EditWeatherCell!
    var indexPath: IndexPath!
    @IBAction func DeleteCell(_ sender: Any) {
        delegate.DeleteTheCell(indexPath: indexPath)
    }
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var TemperatureLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var WeatherImage: UIImageView!
}
