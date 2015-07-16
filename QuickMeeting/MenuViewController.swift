//
//  MenuViewController.swift
//  QuickMeeting
//
//  Created by Justin Sheckler on 7/13/15.
//  Copyright (c) 2015 Justin Sheckler. All rights reserved.
//

import UIKit

enum MenuButtons: Int {
    case Min25 = 100, Min50
}

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton {
            let dest = segue.destinationViewController as! TimerViewController
            let tag = MenuButtons(rawValue: button.tag)
            
            switch tag! {
            case .Min25:
                dest.duration = 25 * 60
                dest.interval = 10 * 60
//                dest.duration = 30
//                dest.interval = 10
            case .Min50:
                dest.duration = 50 * 60
                dest.interval = 10 * 60
            }
        }
    }

}
