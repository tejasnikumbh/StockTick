//
//  DataPoint.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 16/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit
import Foundation

class DataPoint: NSObject {
    let time: UInt64
    let basePrice: Double
    let bestBuyPrice: Double
    let bestBuyQuantity: UInt32
    let bestSellPrice: Double
    let bestSellQuantity: UInt32
    
    init?(time: UInt64, basePrice: Double, bestBuyPrice: Double, bestBuyQuantity: UInt32, bestSellPrice: Double, bestSellQuantity: UInt32) {
        self.time = time
        self.basePrice = basePrice
        self.bestBuyPrice = bestBuyPrice
        self.bestBuyQuantity = bestBuyQuantity
        self.bestSellPrice = bestSellPrice
        self.bestSellQuantity = bestSellQuantity
        // Initialization fails on negative values for prices
        if basePrice < 0 || bestBuyPrice < 0 || bestSellPrice < 0 {
            return nil
        }
    }
    
    class func dataPointFromString(data: String) -> DataPoint? {
        let elements = data.characters.split{$0 == ","}.map(String.init)
        var trimmedElements: [String] = []
        for elem in elements {
            let trimmedElem = elem.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            trimmedElements.append(trimmedElem)
        }
        return DataPoint(time: UInt64(trimmedElements[0])!,
                         basePrice: Double(trimmedElements[1])!,
                         bestBuyPrice: Double(trimmedElements[2])!,
                         bestBuyQuantity: UInt32(trimmedElements[3])!,
                         bestSellPrice: Double(trimmedElements[4])!,
                         bestSellQuantity: UInt32(trimmedElements[5])!)
    }
    
}
    