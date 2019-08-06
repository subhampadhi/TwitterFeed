//
//  TweetsVC.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 30/07/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import UIKit
import Moya

class TweetsVC: TweetsView {
    
    var viewModel: TweetsVM
    
    override func viewDidLoad() {
        setupViews()
        mainTable.dataSource = self
        mainTable.delegate = self
        self.viewModel.tableCellTypes.forEach({ $0.registerCell(tableView: self.mainTable)})
        defineClosures()
        searchController.searchResultsUpdater = self
       // viewModel.getSearchResponse(searchFor: "meme", limitPerCall: 20)
        viewModel.reloadTable?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(vm:TweetsVM) {
        self.viewModel = vm
        super.init()
    }
}

// closure Definations
extension TweetsVC {
    func defineClosures() {
        
        viewModel.showAlert = {  [weak self] (title,message) in
            guard let strongSelf = self else {return}
            Helper.showAlert(title: title, message: message, presenter: strongSelf)
        }
        
        viewModel.reloadTable = { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.viewModel.saveToRealm()
            strongSelf.viewModel.assignTableViewCells()
            strongSelf.mainTable.reloadData()
        }
        
        viewModel.pushViewController = { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// Fuction Defination Extensions

extension TweetsVC {
    
    
    
    @objc func refresh(){
        if !viewModel.checkTokenIssue() {viewModel.getToken()}
        else {
            if let text = searchController.searchBar.text {
                viewModel.getSearchResponse(searchFor: text, limitPerCall: 30)
            }
        }
        refreshControl.endRefreshing()
    }
}

// Search Results

extension TweetsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text{
            viewModel.getSearchResponse(searchFor: text, limitPerCall: 30)
        }
    }
}

extension TweetsVC: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !viewModel.fetchingMore {
                viewModel.getPaginatedData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.moveToProfileScreen(indexPath: indexPath.row)
    }
}


extension TweetsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel.tableCells[indexPath.row]
        return cellViewModel.cellInstantiate(tableView: tableView,indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
