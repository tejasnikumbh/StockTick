//
//  OrderPlacementViewController.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit
import Charts

class OrderPlacementViewController: UIViewController, ChartViewDelegate {
    
    var tickIndex: Int!
    var socket: Socket!
    var currentDataPoint: DataPoint!
    var stockTickData: [DataPoint]!
    var pendingOrderQueue: [Order]!
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var marketOrderQuantity: UITextField!
    @IBOutlet weak var limitOrderQuantity: UITextField!
    @IBOutlet weak var limitOrderPrice: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
        setupStockChart(stockTickData)
        receiveData()
    }
    
    func setupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OrderPlacementViewController.resignKeyboard(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.userInteractionEnabled = true
    }
    func resignKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func setupData() {
        tickIndex = 0
        let dataPoint = DataPoint(time: 1, basePrice: 45.0, bestBuyPrice: 0.0, bestBuyQuantity: 1, bestSellPrice: 0.0, bestSellQuantity: 1)
        stockTickData = [dataPoint!]
        pendingOrderQueue = OrderHistory.sharedInstance.retrievePendingOrders()
    }
    
    func setupStockChart(values: [DataPoint]) {
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(value: values[i].basePrice, xIndex: i)
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "")
        lineChartDataSet.circleRadius = 3.0
        lineChartDataSet.isDrawCircleHoleEnabled
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.circleHoleRadius = 2.0
        lineChartDataSet.circleColors = [UIColor.applicationColor()]
        lineChartDataSet.circleHoleColor = UIColor.whiteColor()
        lineChartDataSet.setColor(UIColor.applicationColor())
        let lineChartData = LineChartData(xVals:values, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        lineChartView.descriptionText = ""
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
    }
    
    func updateStockChart() {
        self.lineChartView.data?.addEntry(ChartDataEntry(value: stockTickData[tickIndex].basePrice, xIndex: tickIndex), dataSetIndex: 0)
        self.lineChartView.data?.addXValue(String(tickIndex))
        self.lineChartView.setVisibleXRange(minXRange: CGFloat(1), maxXRange: CGFloat(50))
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.moveViewToX(CGFloat(tickIndex))
        tickIndex = tickIndex + 1
    }
    
    func receiveData() {
        socket = Socket(host: "0.0.0.0", port: 48129)
        socket.updateDelegate = self
        socket.connect()
    }
    
    @IBAction func placeLimitOrderTapped(sender: UIButton!) {
        guard limitOrderQuantity.text! != "" && limitOrderPrice.text! != ""  else {
            let dialog = UIAlertController.oneButton(message: "Please enter valid quantity and price")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        let action = sender.titleLabel?.text == "BUY" ? OrderAction.BUY : OrderAction.SELL
        
        guard let quantity = Int(limitOrderQuantity.text!) else {
            let dialog = UIAlertController.oneButton(message: "Quantity must be a positive Integer")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        guard let price = Double(limitOrderPrice.text!) else {
            let dialog = UIAlertController.oneButton(message: "Please enter valid quantity and price")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        let order = Order(time: UInt64(NSDate().timeIntervalSince1970), type: .LIMIT, action: action,
                          quantity: UInt32(quantity), price: price, status: .PENDING)
        pendingOrderQueue.append(order!)
        executeLimitOrder()
        let dialog = UIAlertController.oneButton(message: "Your Limit order has been queued")
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    @IBAction func placeMarketOrderTapped(sender: UIButton!) {
        guard marketOrderQuantity.text! != "" else {
            let dialog = UIAlertController.oneButton(message: "Please enter valid quantity and price")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        let action = sender.titleLabel?.text == "BUY" ? OrderAction.BUY : OrderAction.SELL
        guard let quantity = Int(marketOrderQuantity.text!) else {
            let dialog = UIAlertController.oneButton(message: "Quantity must be a positive Integer")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        guard let currentDataPoint = currentDataPoint else { return }
        let order = Order(time: UInt64(NSDate().timeIntervalSince1970), type: .MARKET, action:  action,
                            quantity: UInt32(quantity), price: currentDataPoint.basePrice, status: .PENDING)
        executeMarketOrder(order!)
    }
    
    func executeLimitOrder() {
        while true {
            if pendingOrderQueue.count == 0 { break }
            let order = pendingOrderQueue[0]
            pendingOrderQueue.removeFirst()
            if let result = order.execute(currentDataPoint) {
                pendingOrderQueue.append(result)
                break
            }
        }
    }
    
    func executeMarketOrder(order: Order) {
        if order.execute(currentDataPoint) != nil {
            let dialog = UIAlertController.oneButton(
                message: "Could not execute complete order due to unavailability of stock")
            presentViewController(dialog, animated: true, completion: nil)
            return
        }
        let dialog = UIAlertController.oneButton(message: "Your market order has been placed")
        presentViewController(dialog, animated: true, completion: nil)
        return
    }
    
}

extension OrderPlacementViewController: DataPointStore {
    func storeDataPoint(data: String) {
        let dataPoint = DataPoint.dataPointFromString(data)
        currentDataPoint = dataPoint
        stockTickData.append(dataPoint!)
        updateStockChart()
        executeLimitOrder()
    }
}
