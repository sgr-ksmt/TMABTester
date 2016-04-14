//
//  TMABTesterTests.swift
//  TMABTesterTests
//
//  Created by Suguru Kishimoto on 2016/04/07.
//  Copyright © 2016年 Timers Inc. All rights reserved.
//

import XCTest

enum TestKey: String, TMABTestKey {
    case TestCase1
    case TestCase2
    case TestCase3
    case TestCase4
    case TestCase5
    case TestCase6
    case TestCase7
    case TestCase8
    case TestCase9
    case TestCase10
}

enum TestPattern: Int, TMABTestPattern {
    case A, B, C, D
}

final class ABTester1: TMABTestable {
    typealias Key = TestKey
    typealias Pattern = TestPattern
    
    init () {
        install()
    }
    
    func decidePattern() -> Pattern {
        return Pattern(rawValue: Int(arc4random_uniform(4)))!
    }
    
    var patternSaveKey: String {
        return String(ABTester1.self) + "Pattern"
    }
    
    var checkTiming: TMABTestCheckTiming {
        return .Once
    }
    
    var additionalParameters: TMABTestParameters? {
        return ["sample": 100]
    }
}

class TMABTesterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPoolCount() {
        do {
            let tester = ABTester1()
            XCTAssertEqual(tester.pool?.count, 0)
            tester.addTest(.TestCase1) { _ in }
            XCTAssertEqual(tester.pool?.count, 1)
            tester.removeTest(.TestCase1)
            XCTAssertEqual(tester.pool?.count, 0)
            tester.addTest(.TestCase1) { _ in }
            XCTAssertEqual(tester.pool?.count, 1)
            tester.removeTest(.TestCase2)
            XCTAssertEqual(tester.pool?.count, 1)
        }
        
        do {
            let tester = ABTester1()
            tester.addTest(.TestCase1) { _ in }
            tester.addTest(.TestCase2) { _ in }
            tester.addTest(.TestCase3) { _ in }
            XCTAssertEqual(tester.pool?.count, 3)
            tester.uninstall()
            XCTAssertEqual(tester.pool?.count, 0)
        }
        
        do {
            let tester1 = ABTester1()
            tester1.addTest(.TestCase1) { _ in }
            tester1.addTest(.TestCase2) { _ in }
            tester1.addTest(.TestCase3) { _ in }

            let tester2 = ABTester1()
            tester2.addTest(.TestCase1) { _ in }
            tester2.addTest(.TestCase2) { _ in }
            tester2.addTest(.TestCase3) { _ in }

            XCTAssertEqual(tester1.pool?.count, 3)
            XCTAssertEqual(tester2.pool?.count, 3)
            tester1.uninstall()
            XCTAssertEqual(tester1.pool?.count, 0)
            XCTAssertEqual(tester2.pool?.count, 3)
            
        }
    }
    
    func testExecution() {
        var ex = self.expectationWithDescription(#function)
        let tester = ABTester1()
        let tmpPattern = tester.pattern
        
        tester.addTest(.TestCase1) { pattern, _ in
            XCTAssertEqual(pattern, tmpPattern)
            ex.fulfill()
        }
        tester.addTest(.TestCase2, only: tmpPattern) { pattern, _ in
            XCTAssertEqual(pattern, tmpPattern)
            ex.fulfill()
        }
        
        tester.addTest(.TestCase3, only: [tmpPattern]) { pattern, _ in
            XCTAssertEqual(pattern, tmpPattern)
            ex.fulfill()
        }

        let patterns: [TestPattern] = [.A, .B, .C, .D]
        tester.addTest(.TestCase4, only: patterns.filter { $0 != tmpPattern }) { pattern, _ in
            XCTFail()
        }
        
        tester.addTest(.TestCase5) { pattern, parameters in
            XCTAssertEqual(pattern, tmpPattern)
            XCTAssertEqual(parameters?["foo"] as? Int, 1)
            XCTAssertEqual(parameters?["bar"] as? Int, 2)
            XCTAssertNil(parameters?["baz"])
            ex.fulfill()
        }
        
        tester.addTest(.TestCase6, only: [tmpPattern]) { pattern, parameters in
            XCTAssertEqual(pattern, tmpPattern)
            XCTAssertEqual(parameters?["foo"] as? Int, 1)
            XCTAssertEqual(parameters?["bar"] as? Int, 2)
            XCTAssertNil(parameters?["baz"])
            ex.fulfill()
        }
        
        tester.addTest(.TestCase7) { _, parameters in
            XCTAssertNil(parameters?["foo"])
            XCTAssertNil(parameters?["bar"])
            XCTAssertNil(parameters?["baz"])
            ex.fulfill()
        }
        
        tester.addTest(.TestCase8) { _, parameters in
            XCTAssertNil(parameters?["foo"])
            XCTAssertNil(parameters?["bar"])
            XCTAssertNil(parameters?["baz"])
            XCTAssertEqual(parameters?["sample"] as? Int, 100)
            ex.fulfill()
        }

        tester.addTest(.TestCase9) { _, parameters in
            XCTAssertEqual(parameters?["foo"] as? Int, 1)
            XCTAssertEqual(parameters?["bar"] as? Int, 2)
            XCTAssertNil(parameters?["baz"])
            XCTAssertEqual(parameters?["sample"] as? Int, 100)
            ex.fulfill()
        }

        
        tester.execute(.TestCase1)
        waitForExpectationsWithTimeout(1000) { _ in }
        
        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase1)
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase2)
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase3)
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase4)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1000) { _ in }
        
        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase5, parameters: ["foo": 1, "bar": 2])
        waitForExpectationsWithTimeout(1000) { _ in }
        
        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase6, parameters: ["foo": 1, "bar": 2])
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase7)
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase8)
        waitForExpectationsWithTimeout(1000) { _ in }

        ex = self.expectationWithDescription(#function)
        tester.execute(.TestCase9, parameters: ["foo": 1, "bar": 2])
        waitForExpectationsWithTimeout(1000) { _ in }

    }
}
