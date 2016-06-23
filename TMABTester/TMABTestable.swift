//
//  TMABTestable.swift
//  TMABTester
//
//  Created by Suguru Kishimoto on 2016/04/06.
//  Copyright © 2016 Timers Inc. All rights reserved.
//

import Foundation

public enum TMABTestCheckTiming {
    case once
    case everyTime
}

public protocol TMABTestKey: RawRepresentable {
    associatedtype RawValue = String
}

public protocol TMABTestPattern: RawRepresentable {
    var toObjectForSave: AnyObject { get }
    init(patternObject: AnyObject)
}

public extension TMABTestPattern where RawValue == Int {
    init(patternObject: AnyObject) {
        self.init(rawValue: patternObject as! Int)!
    }

    var toObjectForSave: AnyObject {
        return rawValue as AnyObject
    }
}

public extension TMABTestPattern where RawValue == UInt {
    init(patternObject: AnyObject) {
        self.init(rawValue: patternObject as! UInt)!
    }

    var toObjectForSave: AnyObject {
        return rawValue as AnyObject
    }
}

public extension TMABTestPattern where RawValue == String {
    init(patternObject: AnyObject) {
        self.init(rawValue: patternObject as! String)!
    }

    var toObjectForSave: AnyObject {
        return rawValue as AnyObject
    }
}

public protocol TMABTestable: class {
    associatedtype Key: TMABTestKey, Equatable
    associatedtype Pattern: TMABTestPattern, Equatable
    
    // required
    func decidePattern() -> Pattern
    var patternSaveKey: String { get }
    var checkTiming: TMABTestCheckTiming { get }
    // optional
    var additionalParameters: TMABTestParameters? { get }
}

private struct AssociatedKeys {
    static var TestPoolKey = "FAMABTesterPool"
}

public typealias TMABTestParameters = [String: AnyObject]

public extension TMABTestable where Key.RawValue == String {
    public typealias TMABTestHandler = (Pattern, TMABTestParameters?) -> Void
    
    internal var pool: TMABTestPool? {
        get {
            guard let p = objc_getAssociatedObject(self, &AssociatedKeys.TestPoolKey) as? TMABTestPool else {
                print("Warning : pool is not initialized yet. please call `install()` inside of `init()`")
                return nil
            }
            return p
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.TestPoolKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var pattern: Pattern {
        if case .once = checkTiming where hasPattern {
            return load()
        } else {
            let pattern = decidePattern()
            if case .once = checkTiming {
                save(pattern)
            }
            return pattern
        }
    }
    
    public var additionalParameters: TMABTestParameters? {
        return nil
    }
    
    public func install() {
        self.pool = TMABTestPool()
        _ = pattern // for load pattern immediately
    }
    
    public func uninstall() {
        pool?.removeContainers()
    }
    
    public func resetPattern() {
        UserDefaults.standard().removeObject(forKey: patternSaveKey)
        UserDefaults.standard().synchronize()
        install()
    }
    
    public func addTest(_ key: Key, handler: TMABTestHandler) {
        pool?.add((key: key.rawValue, handler: handler as Any))
    }

    public func addTest(_ key: Key, only target: Pattern, handler: TMABTestHandler) {
        addTest(key, only: [target], handler: handler)
    }
    
    public func addTest(_ key: Key, only targets: [Pattern], handler: TMABTestHandler) {
        addTest(key) { pattern, parameters in
            if !targets.isEmpty && !targets.contains(pattern) {
                return
            }
            handler(pattern, parameters)
        }
    }
    
    public func removeTest(_ key: Key) {
        pool?.remove(key.rawValue)
    }
    
    public func execute(_ key: Key, parameters: TMABTestParameters? = nil) {
        let _handler = pool?.fetchHandler(key.rawValue)
        switch _handler {
        case (let handler as TMABTestHandler):
            handler(pattern, parameters + additionalParameters)
        default:
            fatalError("Error : test is not registered. key = \(key.rawValue), pool = \(pool)")
        }
    }
    
    private var hasPattern: Bool {
        return UserDefaults.standard().object(forKey: patternSaveKey) != nil
    }
    
    private func save(_ pattern: Pattern) {
        UserDefaults.standard().set(pattern.toObjectForSave, forKey: patternSaveKey)
        UserDefaults.standard().synchronize()
    }
    
    private func load() -> Pattern {
        return Pattern(patternObject: UserDefaults.standard().object(forKey: patternSaveKey)!)
    }
}

