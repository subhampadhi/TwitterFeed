//
//  CellFunctions.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 03/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//


import Foundation
import UIKit

protocol CellFunctions {
    
    static func registerCell(tableView : UITableView)
    
    func cellInstantiate(tableView: UITableView,indexPath: IndexPath) -> UITableViewCell
    
    func didSelect(tableView: UITableView, indexPath: IndexPath)
}

extension CellFunctions {
    func didSelect(tableView: UITableView, indexPath: IndexPath) {
    }
}
