//
//  TweetsVM.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 02/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import Moya
import RealmSwift

class TweetsVM {
    
    private let provider = MoyaProvider<TwitterAPI>()
    private var twitterSearchResponse: TwitterSearchResponse?
    var showAlert : ((String,String)->())?
    var reloadTable : (()->())?
    var fetchingMore = false
    var pushViewController :((UIViewController)->())?
    var saved_tweets: Results<Tweets_Realm_Model>?
    let realm = RealmServices.shared.realm
    
    
    let tableCellTypes: [CellFunctions.Type] = [TweetsTVCHelper.self]
    private(set) var tableCells = [CellFunctions]()
    init() {
        getToken()
        
    }
}

extension TweetsVM {
    
    func setUpTableViewCells() -> [CellFunctions] {
        var cellHelpers = [CellFunctions]()
        if twitterSearchResponse == nil {
            let tweetsObjects = realm.objects(Tweets_Realm_Model.self)
            for response in tweetsObjects {
                let newCell = TweetsTVCHelper(userName: response.userName, twitterHandle: response.twitterHandle, tweets:response.tweets, image: response.image, likeCount: response.likeCount, retweetCount: response.retweetCount, userString: response.userString)
                cellHelpers.append(newCell)
            }
            return cellHelpers
        }
        for response in twitterSearchResponse?.statuses ?? [Statuse]() {
            let newCell = TweetsTVCHelper(userName: response.user?.name ?? "", twitterHandle: response.user?.screenName ?? "", tweets: response.text ?? "", image: response.entities?.media?.first?.mediaUrl, likeCount: response.favoriteCount ?? 0, retweetCount: response.retweetCount ?? 0, userString: response.user?.profileImageUrl ?? "")
            cellHelpers.append(newCell)
        }
        return cellHelpers
    }
    
    func assignTableViewCells() {
        self.tableCells = self.setUpTableViewCells()
    }
    
}
// API CALLS AND RELATED FUNCTIONS

extension TweetsVM {
    
    func getToken() {
        if (UserDefaultConstants.getToken() != nil) {
            return
        }
        let header = ["Authorization" : "Basic \(TwitterConstants.getEncodedKey())" , TwitterConstants.CONTENT_TYPE:"application/x-www-form-urlencoded;charset=UTF-8"]
        let params = [TwitterConstants.GRANT_TYPE:"client_credentials"]
        provider.request(.getToken(header: header, params: params)) { (Result) in
            switch Result{
            case .success(let response):
                if Helper.isStatusOK(status: response.statusCode){
                    do {
                        let tokenResponse = try response.map(TokenResponse.self)
                        guard let accessToken = tokenResponse.accessToken else {return}
                        UserDefaultConstants.setToken(token:accessToken)
                    } catch (let error) {
                        self.showAlert?("Oops",error.localizedDescription)
                    }
                }else{
                    self.showAlert?("Oops","Token expired!")
                }
                break
            case .failure(let error):
                self.showAlert?("Oops",error.localizedDescription)
            }
        }
    }
    
    func checkTokenIssue() -> Bool {
        if (UserDefaultConstants.getToken() != nil) {
            return true
        } else {
            self.showAlert?("Oops", "Please check your internet connection and pull to reload")
            return false
        }
    }
    
    func getPaginatedData() {
        if twitterSearchResponse == nil {
            return
        }
        fetchingMore = true
        getNextPageResponse()
    }
    
    func getNextPageResponse(){
        if (UserDefaultConstants.getToken() == nil) {
            getToken()
            return
        }
        let header = ["Authorization" : "Bearer \(UserDefaultConstants.getToken() ?? "")" ,
            TwitterConstants.CONTENT_TYPE : "application/x-www-form-urlencoded"
        ]
        guard let query = twitterSearchResponse?.searchMetadata?.query else {
            return
        }
        guard let count = twitterSearchResponse?.searchMetadata?.count else {
            return
        }
        guard var maxID = twitterSearchResponse?.searchMetadata?.maxIdStr else {
            return
        }
        maxID = "?max_id=" + maxID
        let newCount = "\(count)" + maxID
        print(newCount)
        let params = ["q":query ,
            "result_type":"mixed",
            "count":"\(newCount)",
            "include_entities":"1"
        ]
        provider.request(.getNextTwitterPaginatedResponse(header: header, params: params)) { (Result) in
            switch Result {
            case .success(let response):
                print(response.statusCode)
                do{
                    let searchResponse = try response.map(TwitterSearchResponse.self)
                    for status in searchResponse.statuses ?? [Statuse]() {
                        self.twitterSearchResponse?.statuses?.append(status)
                    }
                    self.twitterSearchResponse?.searchMetadata = searchResponse.searchMetadata
                    self.fetchingMore = false
                    self.reloadTable?()
                }catch(let error) {self.showAlert?("Oops",error.localizedDescription)}
                
            case .failure(let error):
                self.showAlert?("Oops",error.localizedDescription)
            }
        }
        
    }
    
    func getSearchResponse(searchFor:String , limitPerCall:Int) {
        if (UserDefaultConstants.getToken() == nil) {
            getToken()
            return
        }
        let header = ["Authorization" : "Bearer \(UserDefaultConstants.getToken() ?? "")" ,
            TwitterConstants.CONTENT_TYPE : "application/x-www-form-urlencoded"
        ]
        
        let params = ["q":"\(searchFor)" ,
                      "result_type":"mixed",
                      "count":"\(limitPerCall)"
                      ]
        provider.request(.getSearchResponse(header: header, params: params)) { (Result) in
            switch Result{
            case .success(let response):
                if Helper.isStatusOK(status: response.statusCode){
                    
                    do {
                        let searchResponse = try response.map(TwitterSearchResponse.self)
                        self.twitterSearchResponse = searchResponse
                        self.saved_tweets = self.realm.objects(Tweets_Realm_Model.self)
                        
                        self.reloadTable?()
                    } catch (let error) {
                        self.showAlert?("Oops",error.localizedDescription)
                    }
                }else {
                    print("Failed")
                }
                break
            case .failure(let error):
                self.showAlert?("Oops",error.localizedDescription)
                break
            }
        }
    }
}

extension TweetsVM {
    
    func moveToProfileScreen(indexPath:Int) {
        if let user = twitterSearchResponse?.statuses?[indexPath].user{
            let viewModel = ProfileVM(userInfo:user )
            let vc = ProfileVC(vm: viewModel)
            pushViewController?(vc)
        }
    }
    
    func saveToRealm() {
        guard let status = self.twitterSearchResponse?.statuses else{return}
        let realm = RealmServices.shared.realm
        let tweetsObject = realm.objects(Tweets_Realm_Model.self)
        
        try! realm.write {
            realm.delete(tweetsObject)
            
        }
        for response in status {
            let newEntry = Tweets_Realm_Model(userName: response.user?.name ?? "", twitterHandle: response.user?.screenName ?? "", tweets: response.text ?? "", image: response.entities?.media?.first?.mediaUrl ?? "", likeCount: response.favoriteCount ?? 0, retweetCount: response.retweetCount ?? 0, userString: response.user?.profileImageUrl ?? "")
            RealmServices.shared.create(newEntry)
        }
}
}
