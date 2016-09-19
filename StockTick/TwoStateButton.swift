//
//  TwoStateButton.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class TwoStateButton: UIButton {
    func enable() {
        self.enabled = true
        self.backgroundColor = UIColor.whiteColor()
        self.setTitleColor(UIColor.applicationColor(), forState: .Normal)
    }
    func disable() {
        self.enabled = false
        self.backgroundColor = UIColor.lightGrayColor()
        self.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
    }
}