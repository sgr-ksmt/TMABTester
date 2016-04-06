//
//  TMABTester.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/06.
//  Copyright © 2016 Timers Inc. All rights reserved.
//

import Foundation

public enum TMABTestCheckTiming {
    case Once
    case EveryTime
}

public protocol TMABTestKey: RawRepresentable {
    associatedtype RawValue = String
}

public protocol TMABTestPattern: RawRepresentable {
    associatedtype RawValue = Int
}

public protocol TMABTestable: class {
    associatedtype Key: TMABTestKey, Equatable
    associatedtype Pattern: TMABTestPattern, Equatable
    
    func decidePattern() -> Pattern
    var patternSaveKey: String { get }
    var checkTiming: TMABTestCheckTiming { get }
}

public struct AssociatedKeys {
    static var TestPoolKey = "TestPool"
}

public extension TMABTestable where Key.RawValue == String, Pattern.RawValue == Int {
    public typealias TMABTestHandler = Pattern -> Void
    
    internal var pool: TMABTestPool? {
        get {
            guard let p = objc_getAssociatedObject(self, &AssociatedKeys.TestPoolKey) as? TMABTestPool else {
                print("Warning : pool is not initialized yet. please call `install()` inside of `init()`")
                return nil
            }
            return p
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.TestPoolKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var pattern: Pattern {
        if case .Once = checkTiming where hasPattern {
            return load()
        } else {
            let pattern = decidePattern()
            save(pattern)
            return pattern
        }
    }
    
    public func install() {
        self.pool = TMABTestPool()
        _ = pattern // for load pattern immediately
    }
    
    public func uninstall() {
        pool?.removeContainers()
    }
    
    public func resetPattern() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(patternSaveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        install()
    }
    
    public func addTest(key: Key, handler: TMABTestHandler) {
        pool?.add((key: key.rawValue, handler: handler as Any))
    }
    
    public func addTest(key: Key, only target: Pattern, handler: TMABTestHandler) {
        addTest(key, only: [target], handler: handler)
    }
    
    public func addTest(key: Key, only targets: [Pattern], handler: TMABTestHandler) {
        let wrappedHandler: TMABTestHandler = { pattern in
            if !targets.isEmpty && !targets.contains(pattern) {
                return
            }
            handler(pattern)
        }
        addTest(key, handler: wrappedHandler)
    }
    
    public func removeTest(key: Key) {
        pool?.remove(key.rawValue)
    }
    
    public func execute(key: Key) {
        guard let handler = pool?.fetchHandler(key.rawValue) as? TMABTestHandler else {
            fatalError("Error : test is not registered. key = \(key.rawValue), pool = \(pool)")
        }
        handler(pattern)
    }
    
    private var hasPattern: Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(patternSaveKey) != nil
    }
    
    private func save(pattern: Pattern) {
        NSUserDefaults.standardUserDefaults().setInteger(pattern.rawValue, forKey: patternSaveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func load() -> Pattern {
        return Pattern(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(patternSaveKey))!
    }
}

