//
//  Order.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 16/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

enum OrderType {
    case LIMIT
    case MARKET
    static func fromHashValue(hashValue: Int) -> OrderType {
        if hashValue == 0 {
            return .LIMIT
        } else {
            return .MARKET
        }
    }
}

enum OrderAction {
    case BUY
    case SELL
    static func fromHashValue(hashValue: Int) -> OrderAction {
        if hashValue == 0 {
            return .BUY
        } else {
            return .SELL
        }
    }
}

enum OrderStatus {
    case PENDING
    case DONE
    static func fromHashValue(hashValue: Int) -> OrderStatus {
        if hashValue == 0 {
            return .PENDING
        } else {
            return .DONE
        }
    }
}

struct PropertyKey {
    static let timeKey = "time"
    static let typeKey = "type"
    static let actionKey = "action"
    static let quantityKey = "quantity"
    static let priceKey = "price"
    static let statusKey = "status"
}

class Order: NSObject, NSCoding {
    
    // MARK: Other Properties
    
    var time: UInt64
    var type: OrderType
    var action: OrderAction
    var quantity: UInt32
    var price: Double?
    var status: OrderStatus
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("orders")
    
    init?(time: UInt64, type: OrderType, action: OrderAction, quantity: UInt32, price: Double?, status: OrderStatus) {
        self.time = time
        self.type = type
        self.action = action
        self.quantity = quantity
        self.price = price
        self.status = status
        super.init()
        // Initialization fails for invalid values
        if price < 0 {
            return nil
        }
    }
    
    // MARK:- Order Execution Methods
    
    func execute(data: DataPoint) -> Order? {
        // In case of Market Order
        if self.type == .MARKET && self.action == .BUY { return executeMarketBuyOrder(data) }
        if self.type == .MARKET && self.action == .SELL { return executeMarketSellOrder(data) }
        // In case of LIMIT Order
        if self.type == .LIMIT && self.action == .BUY { return executeLimitBuyOrder(data) }
        if self.type == .LIMIT && self.action == .SELL { return executeLimitSellOrder(data) }
        return nil
    }
    
    func executeMarketBuyOrder(data: DataPoint) -> Order? {
        if self.quantity <= data.bestBuyQuantity {
            self.status = .DONE
            OrderHistory.sharedInstance.storeOrder(self)
            return nil
        }
        let orderPartial = Order(time: self.time, type: self.type, action: .BUY, quantity: data.bestBuyQuantity, price: data.bestBuyPrice, status: .DONE)
        OrderHistory.sharedInstance.storeOrder(orderPartial!)
        let quantityRemaining = self.quantity - data.bestBuyQuantity
        let orderRemaining = Order(time: self.time, type: self.type, action: .BUY, quantity: quantityRemaining,price: data.bestBuyPrice, status: .PENDING)
        return orderRemaining
    }
    
    func executeMarketSellOrder(data: DataPoint) -> Order? {
        if self.quantity <= data.bestSellQuantity {
            self.status = .DONE
            OrderHistory.sharedInstance.storeOrder(self)
            return nil
        }
        let orderPartial = Order(time: self.time, type: self.type, action: .SELL, quantity: data.bestSellQuantity, price: data.bestSellPrice, status: .DONE)
        OrderHistory.sharedInstance.storeOrder(orderPartial!)
        let quantityRemaining = self.quantity - data.bestSellQuantity
        let orderRemaining = Order(time: self.time, type: self.type, action: .SELL, quantity: quantityRemaining,price: data.bestSellPrice, status: .PENDING)
        return orderRemaining
    }
    
    func executeLimitBuyOrder(data: DataPoint) -> Order? {
        // If order is already in order history, delete it
        OrderHistory.sharedInstance.deleteOrder(self)
        // Don't fulfill this order since best buy price greater than our order price
        if self.price <= data.bestBuyPrice {
            OrderHistory.sharedInstance.storeOrder(self)
            return self
        }
        // Price condition is satisfied, now onto quantity
        if self.quantity <= data.bestBuyQuantity {
            self.status = .DONE
            OrderHistory.sharedInstance.storeOrder(self)
            return nil
        }
        // Break it into two parts and process
        let orderPartial = Order(time: UInt64(NSDate().timeIntervalSince1970), type: self.type, action: .BUY, quantity: data.bestBuyQuantity, price: data.bestBuyPrice, status: .DONE)
        OrderHistory.sharedInstance.storeOrder(orderPartial!)
        let quantityRemaining = self.quantity - data.bestBuyQuantity
        let orderRemaining = Order(time: UInt64(NSDate().timeIntervalSince1970), type: self.type, action: .BUY, quantity: quantityRemaining,price: self.price, status: .PENDING)
        OrderHistory.sharedInstance.storeOrder(orderRemaining!)
        return orderRemaining
    }
    
    func executeLimitSellOrder(data: DataPoint) -> Order? {
        // If order is already in order history, delete it
        OrderHistory.sharedInstance.deleteOrder(self)
        // Don't fulfill this order since best sell price less than our order price
        if self.price >= data.bestSellPrice {
            OrderHistory.sharedInstance.storeOrder(self)
            return self
        }
        // Price condition is satisfied,now onto quantity
        if self.quantity <= data.bestSellQuantity {
            self.status = .DONE
            OrderHistory.sharedInstance.storeOrder(self)
            return nil
        }
        // Break it into two parts and process
        let orderPartial = Order(time: UInt64(NSDate().timeIntervalSince1970), type: self.type, action: .SELL, quantity: data.bestSellQuantity, price: data.bestSellPrice, status: .DONE)
        OrderHistory.sharedInstance.storeOrder(orderPartial!)
        let quantityRemaining = self.quantity - data.bestSellQuantity
        let orderRemaining = Order(time: UInt64(NSDate().timeIntervalSince1970), type: self.type, action: .SELL, quantity: quantityRemaining,price: self.price, status: .PENDING)
        OrderHistory.sharedInstance.storeOrder(orderRemaining!)
        return orderRemaining
    }
    
    // MARK:- Util Methods
    
    func getFormattedDate() -> String {
        return getDateWithFormat("dd MMM YYYY")
    }
    
    func getFormattedTime() -> String {
        return getDateWithFormat("hh:mm:ss a")
    }
    
    private func getDateWithFormat(format: String) -> String{
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(self.time))
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = format
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        return dateString
    }
    
    func getRoundPrice() -> Double {
        return round(self.price!*100)/100.0
    }
    
    //MARK:- NSCoding Methods
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        let time = NSNumber(unsignedLongLong: self.time)
        aCoder.encodeObject(time, forKey: PropertyKey.timeKey)
        aCoder.encodeInteger(type.hashValue, forKey: PropertyKey.typeKey)
        aCoder.encodeInteger(action.hashValue, forKey: PropertyKey.actionKey)
        let quantity = NSNumber(unsignedInt: self.quantity)
        aCoder.encodeObject(quantity, forKey: PropertyKey.quantityKey)
        aCoder.encodeDouble(price!, forKey: PropertyKey.priceKey)
        aCoder.encodeInteger(status.hashValue, forKey: PropertyKey.statusKey)
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        var time: UInt64!
        if let object = aDecoder.decodeObjectForKey(PropertyKey.timeKey) as? NSNumber {
            time = object.unsignedLongLongValue
        }
        let type =  OrderType.fromHashValue(aDecoder.decodeIntegerForKey(PropertyKey.typeKey))
        let action = OrderAction.fromHashValue(aDecoder.decodeIntegerForKey(PropertyKey.actionKey))
        var quantity: UInt32!
        if let object = aDecoder.decodeObjectForKey(PropertyKey.quantityKey) as? NSNumber {
            quantity = object.unsignedIntValue
        }
        let price = aDecoder.decodeDoubleForKey(PropertyKey.priceKey)
        let status = OrderStatus.fromHashValue(aDecoder.decodeIntegerForKey(PropertyKey.statusKey))
        self.init(time: time, type: type, action: action, quantity: quantity, price: price, status: status)
    }

}
