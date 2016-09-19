//
//  LandingPageViewController.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 14/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController {

    @IBOutlet weak var getStartedButton: TwoStateButton!
    @IBAction func getStartedButtonTapped(sender: TwoStateButton) {
        // Guard In case the Internet is Not available [Relevant if App is on Production]
        guard Reachability.isConnectedToNetwork() else {
            let dialogAlertController = UIAlertController.oneButton(message: "Please enable Internet Connection")
            presentViewController(dialogAlertController, animated: true, completion: nil)
            return
        }
        // Segue to next View Controller
        let tabViewController = storyboard?.instantiateViewControllerWithIdentifier(Constants.kHomeTabBarControllerID) as! HomeTabBarController
        tabViewController.modalTransitionStyle = .FlipHorizontal
        presentViewController(tabViewController, animated: true, completion: nil)
    }
    
}

