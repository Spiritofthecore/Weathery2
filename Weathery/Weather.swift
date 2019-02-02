//
//  File.swift
//  Weathery
//
//  Created by Macbook on 1/23/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import Foundation

//class Weather {
//    var temperature: Double
//    var weatherImageKey: Int
//
//    init(temperature: Double, weatherImageKey: Int) {
//        self.temperature = temperature
//        self.weatherImageKey = weatherImageKey
//    }
//
//    init() {
//        self.temperature = 0
//        self.weatherImageKey = -1
//    }
//}
class Weather: Hashable {
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    var hashValue: Int {
        return Int(locationKey)!
    }
    var temperature: (Double, Double)
    var weatherImageKey: Int
    var realFeelTemperature:(Double, Double)
    var RelativeHumidity: Double
    var WindSpeed: (Double, Double)
    var UVIndex: Double
    var CloudCover: Double
    var Pressure: (Double, Double)
    var locationName: String
    var locationKey: String
    
    init(temperature: (Double, Double), weatherImageKey: Int, realFeelTemperature:(Double, Double), RelativeHumidity: Double, WindSpeed: (Double, Double), UVIndex: Double, CloudCover: Double, Pressure: (Double, Double), locationName: String, locationKey: String) {
        self.temperature = temperature
        self.weatherImageKey = weatherImageKey
        self.realFeelTemperature = realFeelTemperature
        self.RelativeHumidity = RelativeHumidity
        self.WindSpeed = WindSpeed
        self.UVIndex = UVIndex
        self.CloudCover = CloudCover
        self.Pressure = Pressure
        self.locationName = locationName
        self.locationKey = locationKey
    }
    
    init() {
        self.temperature = (0, 0)
        self.weatherImageKey = -1
        self.realFeelTemperature = (0,0)
        self.RelativeHumidity = 0
        self.WindSpeed = (0,0)
        self.UVIndex = 0
        self.CloudCover = 0
        self.Pressure = (0,0)
        self.locationName = ""
        self.locationKey = "0"
    }
    
}
