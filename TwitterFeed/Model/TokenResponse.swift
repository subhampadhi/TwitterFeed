//
//  TokenResponse.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 01/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation

struct TokenResponse : Codable {
    
    let accessToken : String?
    let tokenType : String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
        tokenType = try values.decodeIfPresent(String.self, forKey: .tokenType)
    }
}
