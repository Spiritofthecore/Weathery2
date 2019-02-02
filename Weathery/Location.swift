//
//  Location.swift
//  Weathery
//
//  Created by Macbook on 1/24/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import Foundation
class Location: Hashable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    var hashValue: Int {
        return Int(CityKey)!
    }
    var CityName: String
    var CityKey: String
    init(cityName: String, cityKey: String) {
        self.CityName = cityName
        self.CityKey = cityKey
    }
    init() {
        self.CityName = ""
        self.CityKey = "0"
    }
}
