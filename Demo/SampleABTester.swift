//
//  SampleABTester.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/07.
//  Copyright © 2016年 Suguru Kishimoto. All rights reserved.
//

import Foundation
import TMABTester

enum SampleTestKey: String, TMABTestKey {
    case ChangeLabel
}

enum SampleTestPattern: Int, TMABTestPattern {
    case A, B, C, D
}

final class SampleABTester: TMABTestable {
    typealias Key = SampleTestKey
    typealias Pattern = SampleTestPattern
    
    init () {
        install()
    }
    
    func decidePattern() -> Pattern {
        return Pattern(rawValue: Int(arc4random_uniform(4)))!
    }
    
    var patternSaveKey: String {
        return String(SampleABTester.self) + "Pattern"
    }
    
    var checkTiming: TMABTestCheckTiming {
        return .Once
    }
}