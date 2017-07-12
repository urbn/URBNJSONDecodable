//
//  OperatorTests.swift
//  URBNSwiftyModels
//
//  Created by Joseph Ridenour on 4/14/16.
//  Copyright © 2016 URBN. All rights reserved.
//

import XCTest
import URBNJSONDecodable


/**
 The purpose of these tests are to validate the intentions of 
 convenience operators for getting information from objects 
 */

class OperatorTests: XCTestCase {
   
    func testBasicOperatorExample() {
        
        let testObject: Any = [
            "string": "stringvalue",
            "number": 1,
            "double": 1.1,
            "date": 1233177874
        ]
        
        do {
            
            let stringValue: String = try testObject => "string"
            
            XCTAssertEqual(stringValue, "stringvalue")
            
        } catch {
            XCTFail("Got error parsing testObject: \(error)")
        }
        
    }

    func testOperatorErrors() {
        
        let invalidJson: Any = [1,1,2]
        let json: Any = ["val": "someVal"]
        
        XCTAssertThrowsError(try invalidJson => "fail" as Any, TypeMismatchError.self)
        XCTAssertThrowsError(try json => "blah" as Any, MissingKeyError.self)
        XCTAssertThrowsError(try json => "val" as Int, TypeMismatchError.self)
    }

    func testOperatorChain() {
        
        let json: Any = ["dict": ["x2": ["val": "123"], "x3": ["1","2"]]]
        
        do {
            
            let _: Any = try json => "dict"
            let _: [String: String]? = try json => "dict" => "x2" as? [String: String]
            let _: [String] = try json => "dict" => "x3"
            //TODO: Figure out why this fails
            //let val: String = try json => "dict" => "x2" => "val"
            //XCTAssertEqual(vaal, "123")
            //XCTAssertEqual(x2!, dict["x2"])
            //XCTAssertEqual(x3, dict["x3"])
            
        } catch let err {
            XCTFail("This should not happen.  Got \(err)")
        }
    }

    func testDateParsing() {
        XCTAssertNoThrows(try Date.decode(989797898.0))
        XCTAssertThrowsError(try Date.decode("asdjfij"), TypeMismatchError.self)
    }

    func testLocaleParsing() {
        let localeInfo = ["locale": "en-US"]
        XCTAssertNoThrows(try Locale.decode(localeInfo))
        XCTAssertThrowsError(try Locale.decode("aidsfj"), TypeMismatchError.self)
        
        // Do we want to account for locales that are not on the system?
        XCTAssertThrowsError(try Locale.decode(["locale": "bullshit"]), GeneralError.self)
    }

    func testOptionalOperatorList() {
        let arr = [
            ["val": "someVal"],
            ["val": 1],
            ["val": "blah"]
        ]
        
        let json: Any = ["dict": arr]
        
        let strArr: [String]? = json =>?? "dict" => "val"
        
        XCTAssertEqual(strArr?.count, 2)
    }
    
    func testNestedDictionaryOperators() {
        guard let json = jsonFor("NestedObjectTest") else {
            XCTFail("Error decoding Nested Object Test")
            return
        }
        
        do {
            let nestedContainer = try NestedContainer.decode(json)
            XCTAssertEqual(nestedContainer.nestedObjects.keys.count, 2)
            
            guard let nestedObject = nestedContainer.nestedObjects["FIRST"] else {
                XCTFail("Should serialized nested objects in dicts")
                return
            }
            XCTAssertEqual(nestedObject.string, "STRING")
            XCTAssertEqual(nestedObject.int, 42)
        }
        catch {
            XCTFail("Error decoding NestedObjects: \(error)")
        }
    }
}

//MARK: Test Objects
class NestedObject: NSObject, JSONDecodable {
    let string: String
    let int: Int
    
    public required init(json: Any) throws {
        self.string = try json => "string"
        self.int = try json => "int"
    }
    
    static func decode(_ json: Any) throws -> Self {
        return try self.init(json: json)
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}

class NestedContainer: NSObject, JSONDecodable {
    let nestedObjects: [String: NestedObject]
    
    public required init(json: Any) throws {
        self.nestedObjects = try json => "nestedObject"
    }
    
    static func decode(_ json: Any) throws -> Self {
        return try self.init(json: json)
    }
    
    public override var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}
