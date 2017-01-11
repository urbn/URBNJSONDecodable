//
//  Errors.swift
//  URBNJSONdecodable
//

import Foundation

public protocol ModelMappingError: Error {
    var path: [String] { get set }
    var object: Any { get }
    var rootObject: Any? { get set }
    
    var formattedPath: String { get }
}

extension ModelMappingError {
    public var formattedPath: String {
        return path.joined(separator: ".")
    }
}

public struct TypeMismatchError: ModelMappingError {
    
    let expectedType: Any.Type
    let actualType: Any.Type
    
    public var path: [String]
    public var object: Any
    public var rootObject: Any?
    
    public init(expected: Any.Type, actual: Any.Type, object: Any, rootObject: Any? = nil) {
        self.expectedType = expected
        self.actualType = actual
        self.object = object
        self.rootObject = rootObject
        self.path = []
    }
}

public struct MissingKeyError: ModelMappingError {
    
    public let missingKey: String
    
    public var path: [String]
    public var object: Any
    public var rootObject: Any?
    
    public init(missingKey: String, onObject: Any) {
        self.missingKey = missingKey
        self.object = onObject
        self.path = []
    }
}

public struct RawRepresentableError: ModelMappingError {
    public let type: Any.Type
    public let rawValue: Any
    
    public var path: [String]
    public let object: Any
    public var rootObject: Any?
    
    public init(type: Any.Type, rawValue: Any, object: Any) {
        self.rawValue = rawValue
        self.type = type
        self.object = object
        self.path = []
    }
    
    public var debugDescription: String {
        return "RawRepresentableError: \(rawValue) could not be used to initialize \(type). (path: \(path))"
    }
}

public struct InvalidURLError: ModelMappingError {
    public var path: [String]
    public var object: Any
    public var rootObject: Any?
    
    public init(urlString: Any) {
        self.object = urlString
        self.path = []
    }
}

public struct GeneralError: ModelMappingError, CustomStringConvertible {
    public var path: [String]
    public let object: Any
    public var rootObject: Any?
    
    public var details: String
    
    public init(object: Any, description: String) {
        self.object = object
        self.details = description
        self.path = []
    }
    
    public var description: String {
        return "GeneralError: \(details)"
    }
}
