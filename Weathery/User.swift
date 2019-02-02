//
//  User.swift
//  Weathery
//
//  Created by Macbook on 1/26/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import Foundation

class User {
    var userName: String!
    var userID: String?
    var userImageURL: URL?
    
    init(username: String, userid: String, userimageurl: URL) {
        self.userName = username
        self.userID = userid
        self.userImageURL = userimageurl
    }
    init() {
        self.userName = "not yet sign in"
    }
}
