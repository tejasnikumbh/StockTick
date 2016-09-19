//
//  OrderHistory.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 16/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class OrderHistory {
    
    private var orders: [Order] = []
    private var pendingOrders: [Order] = []
    
    static let sharedInstance = OrderHistory()
    
    private init() {
        retrieveFromLocalStorage()
        for order in orders {
            if order.status == .PENDING {
                pendingOrders.append(order)
            }
        }
    }
    
    // MARK:- Order Store, Retrieve, Delete Methods
    
    func storeOrder(order: Order) {
        var index = -1
        for i in Range(0..<orders.count) {
            if orders[i] == order {
                index = i
                break
            }
        }
        if index == -1 {
            orders.append(order)
        }
    }
    
    func deleteOrder(order: Order) {
        var index = -1
        for i in Range(0..<orders.count) {
            if orders[i] == order {
                index = i
                break
            }
        }
        if index != -1 {
            orders.removeAtIndex(index)
        }
    }
    
    func retrieveOrders() -> [Order]{
        return orders
    }
    func retrievePendingOrders() -> [Order] {
        return pendingOrders
    }
    
    // MARK:- Persistence Methods
    
    func saveToLocalStorage() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(orders, toFile: Order.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }
    private func retrieveFromLocalStorage() {
        if let ordersList = (NSKeyedUnarchiver.unarchiveObjectWithFile(Order.ArchiveURL.path!) as? [Order]) {
            orders = ordersList
        }
    }
}