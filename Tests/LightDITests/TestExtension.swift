//
//  File.swift
//

import Foundation

import XCTest

// TODO: find a way to move these test extensions to a package in core that can be loaded my other tests
extension XCTestCase {

    public func assertNotEmpty<T: Hashable, V>(_ data: Dictionary<T, V>?, _ message: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(data, message, file: file, line: line)
        XCTAssertGreaterThan(data!.count, 0, message, file: file, line: line)
    }

    public func assertNotEmpty<T>(_ data: Array<T>?, _ message: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(data, message, file: file, line: line)
        XCTAssertGreaterThan(data!.count, 0, message, file: file, line: line)
    }

    public func assertEmpty<T: Hashable, V>(_ data: Dictionary<T, V>?, _ message: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(data, message, file: file, line: line)
        XCTAssertEqual(data!.count, 0, message, file: file, line: line)
    }

    public func assertEmpty<T>(_ data: Array<T>?, _ message: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(data, message, file: file, line: line)
        XCTAssertEqual(data!.count, 0, message, file: file, line: line)
    }

    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
