//
//  JSONDecodable.swift
//  URBNJSONdecodable
//

import Foundation

public protocol JSONDecodable {
    static func decode(_ json: Any) throws -> Self
}

/// Represents a JSONDecodable where the json is expected to be
/// the type
public protocol JSONDecodableLiteral: JSONDecodable { }

extension JSONDecodableLiteral {
    public static func decode(_ json: Any) throws -> Self {
        guard let val = json as? Self else {
            throw TypeMismatchError(expected: self, actual: type(of: json).self, object: json)
        }
        return val
    }
}


extension String: JSONDecodableLiteral {}
extension Int: JSONDecodableLiteral {}
extension Double: JSONDecodableLiteral {}
extension Bool: JSONDecodableLiteral {}

extension Array where Element: JSONDecodable {
    
    /**
     The purpose of this method is to decode things while throwing out invalid
     elements.
     ```
     [String].decode(json: [1, "2", true])
     
     Output: ["2"]
     ```
     */
    public static func decodeAllowInvalid(_ json: Any) throws -> [Element] {
        let jsonVal: [Any] = try checkType(json)
        return jsonVal.flatMap({ try? Element.decode($0) })
    }
    
    public static func decode(_ json: Any) throws -> [Element] {
        let jsonVal: [Any] = try checkType(json)
        return try jsonVal.map({ try Element.decode($0) })
    }
}

extension NSArray {
    public static func decode(_ json: Any) throws -> NSArray {
        return try checkType(json)
    }
}

extension Dictionary where Key: JSONDecodable, Value: JSONDecodable {
    public static func decodeAllowInvalid(_ json: Any) throws -> [Key: Value] {
        let jsonVal: [String: Any] = try checkType(json)
        
        var d = [Key: Value]()
        for (k, v) in jsonVal {
            guard let key = try? Key.decode(k), let value = try? Value.decode(v) else { continue }
            
            d[key] = value
        }
        
        return d
    }
    
    public static func decode(_ json: Any) throws -> [Key: Value] {
        let jsonVal: [String: Any] = try checkType(json)
        
        var d = [Key: Value]()
        for (k, v) in jsonVal {
            do {
                let key = try Key.decode(k)
                let value = try Value.decode(v)
                
                d[key] = value
            }
        }
        
        return d
    }
}

extension NSDictionary {
    public static func decode(_ json: Any) throws -> NSDictionary {
        return try checkType(json)
    }
}

extension RawRepresentable where RawValue: JSONDecodable {
    public static func decode(_ json: Any) throws -> Self {
        guard let val = try self.init(rawValue: RawValue.decode(json)) else {
            throw RawRepresentableError(type: self, rawValue: json, object: json)
        }
        
        return val
    }
}

extension Date: JSONDecodable {
    public static func decode(_ json: Any) throws -> Date {
        guard let dateDouble = json as? Double else {
            throw TypeMismatchError(expected: Double.self, actual: type(of: json).self, object: json)
        }
        
        return self.init(timeInterval:0, since:Date.init(timeIntervalSince1970: dateDouble))
    }
}

extension Locale: JSONDecodable {
    public static func decode(_ json: Any) throws -> Locale {
        // The service returns `en-US`, apple uses `en_US` in the availableLocaleIdentifiers portion.
        // This snippet is to normalize the process so no matter what here we'll get `en_US`
        let localeIdentifier: String = try json => "locale"
        let locale = Locale(identifier: localeIdentifier)
        
        guard let country = locale.regionCode, let language = locale.languageCode, Locale.isoLanguageCodes.contains(language) && Locale.isoRegionCodes.contains(country) else {
            throw GeneralError(object: localeIdentifier, description: "Locale \(localeIdentifier) is not recognized by the iOS system.  See `Locale.availableidentifiers`")
        }
        
        return self.init(identifier: localeIdentifier)
    }
}



extension URL: JSONDecodable {
    public static func decode(_ json: Any) throws -> URL {
        guard let urlString = json as? String else {
            throw TypeMismatchError(expected: String.self, actual: type(of: json).self, object: json)
        }
        
        guard let url = self.init(string: urlString) else {
            throw InvalidURLError(urlString: urlString)
        }
        
        return url
    }
}
