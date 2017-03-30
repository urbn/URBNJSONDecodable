//
//  Operators.swift
//  URBNJSONdecodable
//

import Foundation

precedencegroup DecodingPrecedence {
    associativity: right
    higherThan: CastingPrecedence
}

infix operator => : DecodingPrecedence
infix operator =>? : DecodingPrecedence
infix operator =>?? : DecodingPrecedence

internal typealias BaseObjectType = [String: Any]
internal typealias BaseArrayType = [Any]

internal func decodeObject(_ obj: Any) throws -> BaseObjectType {
    guard let lhsVal = obj as? BaseObjectType else {
        throw TypeMismatchError(expected: BaseObjectType.self, actual: type(of: obj).self, object: obj)
    }
    return lhsVal
}

internal func decodeArray(_ obj: Any) throws -> BaseArrayType {
    guard let lhsVal = obj as? BaseArrayType else {
        throw TypeMismatchError(expected: BaseArrayType.self, actual: type(of: obj).self, object: obj)
    }
    return lhsVal
}

internal func checkKey(_ obj: BaseObjectType, key: String, root: Any? = nil) throws -> Any {
    guard let val = obj[key] else {
        throw MissingKeyError(missingKey: key, onObject: obj)
    }
    
    return val
}

internal func checkKey(_ obj: BaseArrayType, key: String, root: Any? = nil) throws -> [Any] {
    return try obj.map({ try checkKey(try decodeObject($0), key: key) })
}

internal func checkType<T>(_ obj: Any, root: Any? = nil) throws -> T {
    guard let val = obj as? T else {
        var err = TypeMismatchError(expected: T.self, actual: type(of: obj).self, object: obj)
        err.rootObject = root ?? obj
        throw err
    }
    return val
}

// MARK: - Basics
public func =>(lhs: Any, rhs: String) throws -> Any {
    
    /// First check if is array
    switch lhs {
    case is BaseArrayType:
        return try checkKey(try decodeArray(lhs), key: rhs, root: lhs)
    default:
        return try checkKey(try decodeObject(lhs), key: rhs, root: lhs)
    }
}

public func =>(lhs: Any, path: [String]) throws -> Any {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    return value
}

//TODO: For Some reason this is breaking the decoding
//public func =>(lhs: Any, rhs: String) throws -> [Any] {
//    let json = try decodeObject(lhs)
//    let jsonVal = try checkKey(json, key: rhs, root: lhs)
//    guard let val = jsonVal as? [Any] else {
//        throw TypeMismatchError(expected: [Any].self,
//                                actual: type(of: jsonVal).self,
//                                object: jsonVal,
//                                rootObject: lhs)
//    }
//
//    return val
//}

// MARK: - Paths
public func =>(lhs: String, rhs: String) -> [String] {
    return [lhs, rhs]
}

public func =>(lhs: String, rhs: [String]) -> [String] {
    return [lhs] + rhs
}

// MARK: - Generics
public func =><T: JSONDecodable>(lhs: Any, rhs: String) throws -> T {
    return try lhs => [rhs]
}

public func =><T: JSONDecodable>(lhs: Any, path: [String]) throws -> T {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    let jsonValue: Any = try checkType(value, root: lhs)
    return try T.decode(jsonValue)
}

public func =><T: JSONDecodable>(lhs: Any, rhs: String) throws -> [T] {
    return try lhs => [rhs]
}

public func =><T: JSONDecodable>(lhs: Any, path: [String]) throws -> [T] {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    return try [T].decode(value)
}

public func =>?<T: JSONDecodable>(lhs: Any, rhs: String) throws -> [T] {
    return try lhs =>? [rhs]
}

public func =>?<T: JSONDecodable>(lhs: Any, path: [String]) throws -> [T] {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    return try [T].decodeAllowInvalid(value)
}

public func =>?<T: JSONDecodable>(lhs: Any, rhs: String) throws -> [String: T] {
    return try lhs =>? [rhs]
}

public func =>?<T: JSONDecodable>(lhs: Any, path: [String]) throws -> [String: T] {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    return try [String: T].decodeAllowInvalid(value)
}

/// Decoding to Any / [Any]
public func =><T: Any>(lhs: Any, path: String) throws -> [T] {
    return try lhs => [path]
}

public func =><T: Any>(lhs: Any, path: [String]) throws -> [T] {
    let value = try path.reduce(lhs, { (val, key) -> Any in
        return try val => key
    })
    
    if let arr = value as? [T] {
        return arr
    }
    
    throw TypeMismatchError(expected: [Any].self, actual: type(of: value), object: value)
}

public func =>??<T: Any>(lhs: Any?, path: String) -> [T]? {
    guard let lhs = lhs else { return nil }
    return try? lhs => [path]
}

public func =>??<T: Any>(lhs: Any?, path: [String]) -> [T]? {
    guard let lhs = lhs else { return nil }
    return try? lhs => path
}

/// Try to decode as T, or throw. Will return nil if the object at the keypath is NSNull.
public func =>?? <T: JSONDecodable>(lhs: Any?, rhs: String) -> T? {
    guard let lhs = lhs else { return nil }
    return lhs =>?? [rhs]
}

public func =>??<T: JSONDecodable>(lhs: Any?, path: [String]) -> T? {
    guard let lhs = lhs else { return nil }
    return try? lhs => path
}

public func =>??<T: JSONDecodable>(lhs: Any?, rhs: String) -> [T]? {
    guard let lhs = lhs else { return nil }
    return lhs =>?? [rhs]
}

public func =>??<T: JSONDecodable>(lhs: Any?, path: [String]) -> [T]? {
    guard let lhs = lhs else { return nil }
    return try? lhs =>? path
}

public func =>??<T: JSONDecodable>(lhs: Any?, rhs: String) -> [String: T]? {
    guard let lhs = lhs else { return nil }
    return lhs =>?? [rhs]
}

public func =>??<T: JSONDecodable>(lhs: Any?, path: [String]) -> [String: T]? {
    guard let lhs = lhs else { return nil }
    return try? lhs =>? path
}

public func =><T>(lhs: Any, path: String) throws -> [String: T] {
    if let json = lhs as? [String: Any],
        let dict = json[path] as? [String: T]{
        return dict
    }

    throw TypeMismatchError(expected: [String: Any].self, actual: type(of: lhs), object: lhs)
}

public func =>??<T>(lhs: Any?, path: String) -> [String: T]? {
    guard let lhs = lhs else { return nil }
    return try? lhs => path
}
