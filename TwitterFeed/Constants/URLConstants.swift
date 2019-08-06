//
//  URLConstants.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 30/07/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import UIKit

class URLConstants {
    
    static let TWITTER_BASE_URL = "https://api.twitter.com/"
}

class TwitterConstants {
    
    private static let API_KEY = "yD7KaBsAJSjqeOLXTucW2pVCz"
    private static let API_SECRET_KEY = "kQdZMLEPXja7WkDsqRcHYUSFhl9z0lp6pbLzBJScgynrYQgkMF"
    static let CONTENT_TYPE = "Content-Type"
    static let GRANT_TYPE = "grant_type"
    static func getApiKey() -> String {
        return API_KEY
    }
    
    static func getApiSecretKey()-> String {
        return API_SECRET_KEY
    }
    
    static func getEncodedKey() -> String {
       let uRLEncodedAPIKey = Helper.convertToURLEncoding(string: API_KEY)
       let uRLEncodedAPISecretKey = Helper.convertToURLEncoding(string: API_SECRET_KEY)
        let encodedKey = "\(uRLEncodedAPIKey):\(uRLEncodedAPISecretKey)"
        return encodedKey.toBase64()
    }
}


