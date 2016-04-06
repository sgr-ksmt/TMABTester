//
//  TMABTestContainer.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/06.
//  Copyright © 2016 Timers Inc. All rights reserved.
//

import Foundation

internal struct TMABTestContainer: Equatable {
    let key: String
    let handler: Any
    
    init(_ test: (key: String, handler: Any)) {
        self.key = test.key
        self.handler = test.handler
    }
}

internal func == (lhs: TMABTestContainer, rhs: TMABTestContainer) -> Bool {
    return lhs.key == rhs.key
}
