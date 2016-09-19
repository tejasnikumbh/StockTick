//
//  HistoryViewController.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var orderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        orderTableView.reloadData()
    }
    func setupView() {
        orderTableView.dataSource = self
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    
    // MARK:- TableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("orderTableViewCell") as! OrderTableViewCell
        let count = OrderHistory.sharedInstance.retrieveOrders().count
        // To Sort in descending order
        let cellModel = OrderHistory.sharedInstance.retrieveOrders()[count - indexPath.row - 1]
        cell.dateLabel.text = cellModel.getFormattedDate()
        cell.timeLabel.text = cellModel.getFormattedTime()
        cell.unitsLabel.text = String(cellModel.quantity)
        cell.pricePerUnitLabel.text = String(cellModel.getRoundPrice())
        setOrderTypeView(cellModel, cell: cell)
        setOrderActionView(cellModel, cell: cell)
        setOrderStatusView(cellModel, cell: cell)
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderHistory.sharedInstance.retrieveOrders().count
    }
    
    // MARK:- Cell View Sub Methods
    
    func setOrderTypeView(cellModel: Order, cell: OrderTableViewCell) {
        if cellModel.type == .LIMIT {
            cell.orderTypeButton.backgroundColor = UIColor.applicationYellowColor()
            cell.orderTypeButton.setTitle("LIMIT", forState: .Normal)
        } else {
            cell.orderTypeButton.backgroundColor = UIColor.applicationColor()
            cell.orderTypeButton.setTitle("MARKET", forState: .Normal)
        }
    }
    func setOrderActionView(cellModel: Order, cell: OrderTableViewCell) {
        if cellModel.action == .BUY {
            cell.orderActionButton.backgroundColor = UIColor.applicationGreenColor()
            cell.orderActionButton.setTitle("BUY", forState: .Normal)
        } else {
            cell.orderActionButton.backgroundColor = UIColor.applicationMaroonColor()
            cell.orderActionButton.setTitle("SELL", forState: .Normal)
        }
    }
    func setOrderStatusView(cellModel: Order, cell: OrderTableViewCell) {
        if cellModel.status == .DONE {
            cell.statusButton.backgroundColor = UIColor.applicationGreenColor()
            cell.statusButton.setTitle("DONE", forState: .Normal)
        } else {
            cell.statusButton.backgroundColor = UIColor.redColor()
            cell.statusButton.setTitle("PENDING", forState: .Normal)
        }
    }
}