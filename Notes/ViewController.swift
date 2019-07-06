//
//  ViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-03.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        #if DARKMODE
            self.view.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1)
        #else
            self.view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 247.0/255.0, alpha: 1)
        #endif
    }
}

