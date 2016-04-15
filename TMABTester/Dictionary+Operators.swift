//
//  Dictionary+Operators.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/15.
//  Copyright © 2016年 Suguru Kishimoto. All rights reserved.
//

import Foundation

extension Dictionary {
    public func union(other: Dictionary) -> Dictionary {
        var tmp = self
        other.forEach { tmp[$0.0] = $0.1 }
        return tmp
    }
}


func +<K, V>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) -> Dictionary<K, V> {
    return lhs.union(rhs)
}

func +=<K, V>(inout lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) {
    lhs = lhs + rhs
}

func +<K, V>(lhs: Dictionary<K, V>?, rhs: Dictionary<K, V>?) -> Dictionary<K, V>? {
    switch (lhs, rhs) {
    case (.Some(let l), .Some(let r)):
        return l + r
    case (.Some(let l), .None):
        return l
    case (.None, .Some(let r)):
        return r
    default:
        return nil
    }
}

func +=<K, V>(inout lhs: Dictionary<K, V>?, rhs: Dictionary<K, V>?) {
    lhs = lhs + rhs
}
