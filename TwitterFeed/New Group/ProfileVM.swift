//
//  ProfileVM.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 04/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import Moya

class ProfileVM {
    
    var userInfo: User
    let tableCellTypes: [CellFunctions.Type] = [TweetsTVCHelper.self , ProfileHeaderTVCHelper.self]
    private(set) var tableCells = [CellFunctions]()
    var reloadTable : (()->())?
    let coverPictureURL: URL?
    private let provider = MoyaProvider<TwitterAPI>()
    private var userTweets = [UserTweets]()
    var showAlert : ((String,String)->())?
    
    init(userInfo:User) {
        self.userInfo = userInfo
        coverPictureURL = URL(string:userInfo.profileBannerUrl ?? "")
    }
    
    func assignTableViewCells() {
        self.tableCells = self.setUpTableViewCells()
    }
    
    func setUpTableViewCells() -> [CellFunctions]{
        var cellHelpers = [CellFunctions]()
        
        let newCell = ProfileHeaderTVCHelper(userName: userInfo.name ?? "",twitterHandle: userInfo.screenName ?? "", tweets: userInfo.idStr ?? "", profileImage: userInfo.profileImageUrl, followingCount: userInfo.favouritesCount ?? 0, followersCount: userInfo.followersCount ?? 0, coverImage: userInfo.profileBannerUrl, joiningDate: userInfo.createdAt ?? "", location: userInfo.location ?? "", description: userInfo.descriptionField ?? "")
            cellHelpers.append(newCell)
        
        if userTweets.count > 0 {
            for tweets in userTweets  {
                let tweetCell = TweetsTVCHelper(userName: tweets.user?.name ?? "", twitterHandle: tweets.user?.screenName ?? "", tweets: tweets.text ?? "", image: tweets.entities?.media?.first?.mediaUrl, likeCount: tweets.favoriteCount ?? 0, retweetCount: tweets.retweetCount ?? 0, userString: tweets.user?.profileImageUrl ?? "")
                cellHelpers.append(tweetCell)
            }
        }
        return cellHelpers
    }
}

extension ProfileVM {
    
    func getUserTweets() {
        if (UserDefaultConstants.getToken() == nil) {
            return
        }
        guard let screenName = userInfo.screenName else {return}
        let header = ["Authorization" : "Bearer \(UserDefaultConstants.getToken() ?? "")" ,
            TwitterConstants.CONTENT_TYPE : "application/x-www-form-urlencoded"
        ]
        
        let params = ["screen_name":"\(screenName)"
        ]
        provider.request(.getUserTweets(header: header, params: params)) { (Result) in
            switch Result{
            case .success(let response):
                do{
                    let response = try response.map([UserTweets].self)
                    self.userTweets = response
                    DispatchQueue.main.async {
                        self.reloadTable?()
                    }
                }catch(let error){
                    self.showAlert?("Oops",error.localizedDescription)
                }
            case .failure(let error):
                self.showAlert?("Oops",error.localizedDescription)
            }
        }
        
    }
}
