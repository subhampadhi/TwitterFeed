//
//  UserDefaultConstants.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 02/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation

class UserDefaultConstants {
    
    static private let TOKEN = "Token"
    
    static func setToken(token:String) {
        UserDefaults.standard.set(token, forKey: TOKEN)
    }
    
    static func getToken() -> String? {
        return UserDefaults.standard.string(forKey: TOKEN) 
    }
}
