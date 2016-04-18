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
//        tester.resetPattern()
        tester.addTest(.ChangeLabel) { [weak self] pattern, parameters in
            let type = parameters?["type"] as? String
            let num = parameters?["num"] as? Int
            let text = "Pattern is \(pattern.rawValue)" + (type.map { "_\($0)" } ?? "") + (num.map { "_\($0)" } ?? "")
            self?.label.text = text
        }
        tester.execute(.ChangeLabel, parameters: ["num": 100])
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

