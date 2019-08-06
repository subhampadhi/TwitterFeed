//
//  Helper.swift
//  TwitterFeed
//
//  Created by Subham Padhi on 01/08/19.
//  Copyright © 2019 Subham Padhi. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func convertToURLEncoding(string:String) -> String {
        let allowedQueryParamAndKey =  NSCharacterSet(charactersIn: ";/?:@&=+$, ").inverted
        return string.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? ""
    }
    
    static func isStatusOK(status: Int) -> Bool {
        if status == 200 {return true}
        return false
    }
    
    static func showAlert(title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        presenter.present(alert, animated: true, completion: nil)
    }
    
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension Double {
    var kmFormatted: String {
        if self >= 1000, self <= 999999 {
            return String(format: "%.1fK", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", locale: Locale.current,self)
    }
}
