//
//  HomeTabBarController.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let orders = tabBar.items![0]
        let history = tabBar.items![1]
        orders.title = "Orders"
        history.title = "History"
        orders.image = UIImage(named: "orders")
        history.image = UIImage(named: "history")
    }
    
}
