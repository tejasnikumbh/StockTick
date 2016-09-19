//
//  UIAlertViewController.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func oneButton(title: String? = Constants.kAppName, message: String)  -> UIAlertController {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: Constants.kOkayMessage,
            style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
}
