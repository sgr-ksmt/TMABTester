//
//  TMABTestPool.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/06.
//  Copyright © 2016 Timers Inc. All rights reserved.
//

import Foundation

internal final class TMABTestPool {
    private var containers = [TMABTestContainer]()
    var count: Int {
        return containers.count
    }
    
    init () {}
    
    func add(test: (key: String, handler: Any)) {
        if let _ = containers.filter({ $0.key == test.key }).first {
            fatalError("Error : This test Already added. key : \(test.key)")
        }
        containers.append(TMABTestContainer(test))
    }
    
    func fetchHandler(key: String) -> Any? {
        return containers.filter { $0.key == key }.first?.handler
    }
    
    func remove(key: String) {
        containers = containers.filter { $0.key != key }
    }
    
    func removeContainers() {
        containers.removeAll()
    }
    
    deinit {
        removeContainers()
    }
}
