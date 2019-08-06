//
//  Tweets_Realm_Model.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 05/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Tweets_Realm_Model: Object {
    
    convenience init(userName: String, twitterHandle: String, tweets: String, image: String, likeCount: Int, retweetCount: Int, userString: String) {
        self.init()
        self.userName = userName
        self.twitterHandle = twitterHandle
        self.tweets = tweets
        self.image = image
        self.likeCount = likeCount
        self.retweetCount = retweetCount
        self.userString = userString
    }
    
    @objc dynamic var userName: String = ""
    @objc dynamic var twitterHandle:String = ""
    @objc dynamic var tweets: String =  ""
    @objc dynamic var image: String  = ""
    @objc dynamic var likeCount: Int = 0
    @objc dynamic var retweetCount: Int = 0
    @objc dynamic var userString: String = ""
}
