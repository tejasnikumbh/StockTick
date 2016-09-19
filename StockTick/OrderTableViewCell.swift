//
//  OrderTableViewCell.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 16/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var pricePerUnitLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
}
