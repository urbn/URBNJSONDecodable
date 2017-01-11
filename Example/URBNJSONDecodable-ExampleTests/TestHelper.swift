//
//  URBNTestHelper.swift
//  URBNSwiftyModels
//
//  Created by Kevin Taniguchi on 3/27/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

public func jsonFor(_ path: String, ext: String = "json") -> Any? {
    
    if let testBundle = Bundle(identifier: "com.urbn.URBNSwiftyModelsTests"), let path = testBundle.path(forResource: path, ofType: ext), let d = try? Data(contentsOf: URL(fileURLWithPath: path)) {
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
        XCTFail("Expected error of \(E.self) got \(type(of: err).self) - \(message)", file: file, line: line)
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
