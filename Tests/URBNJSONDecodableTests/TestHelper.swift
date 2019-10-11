//
//  URBNTestHelper.swift
//  URBNSwiftyModels
//
//  Created by Kevin Taniguchi on 3/27/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

public func nestedObjectJSON() -> Any? {
    
let nestedObjectString = """
    {
        "nestedObject": {
            "FIRST": {
                "string": "STRING",
                "int": 42
            },
            "SECOND": {
                "string": "STRING",
                "int": 42
            }
        }
    }
"""
    
    if let d = nestedObjectString.data(using: .utf8) {
        return try? JSONSerialization.jsonObject(with: d, options: [])
    }
    
    return nil
}


public func XCTAssertThrowsError<T, E>(_ expression: @autoclosure () throws -> T, _ type: E.Type, _ message: String = "", file: StaticString = #file, line: UInt = #line) where E: Error {
    
    do {
        
        _ = try expression()
        XCTFail("No error to catch! - \(message)", file: file, line: line)
        
    }
    catch is E { }
    catch let err {
        XCTFail("Expected error of \(E.self) got \(Swift.type(of: err).self) - \(message)", file: file, line: line)
    }
}

public func XCTAssertNoThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    
    do {
        
        _ = try expression()
    }
    catch let err {
        XCTFail("Expected not to throw error got \(type(of: err).self) - \(message)", file: file, line: line)
    }
}

public func ModelDescriptor(_ object: AnyObject, extra: String) -> String {
    return "<\(type(of: object)): \(Unmanaged.passUnretained(object).toOpaque())> - " + extra
}
