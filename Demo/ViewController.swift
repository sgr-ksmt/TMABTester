//
//  ViewController.swift
//  Demo
//
//  Created by Suguru Kishimoto on 2016/04/07.
//  Copyright © 2016年 Timers Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var  label: UILabel!
    
    private lazy var tester = SampleABTester()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tester.addTest(.ChangeLabel) { [weak self] pattern in
            self?.label.text = "Pattern is \(pattern)"
        }
        tester.execute(.ChangeLabel)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

