//
//  Codable+.swift
//  CZUtils
//
//  Created by Cheng Zhang on 12/31/18.
//  Copyright © 2018 Cheng Zhang. All rights reserved.
//

import Foundation

public class CodableHelper {
  
  /// Decode model from specified file
  ///
  /// - Parameter pathUrl: pathUrl of file
  /// - Returns: the decoded model
  public static func decode<T: Decodable>(_ pathUrl: URL) -> T? {
    do {
      let jsonData = try Data(contentsOf: pathUrl)
      let model = try JSONDecoder().decode(T.self, from: jsonData)
      return model
    } catch {
      assertionFailure("Failed to decode JSON file \(pathUrl) of \(T.self). Error - \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Decode model from input data
  ///
  /// - Parameter data: serialized data
  /// - Returns: the decoded model
  public static func decode<T: Decodable>(_ data: Data?) -> T? {
    guard let data = data else { return nil}
    do {
      let model = try JSONDecoder().decode(T.self, from: data)
      return model
    } catch {
      assertionFailure("Failed to decode data of \(T.self). Error - \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Decode model from input jsonObject
  ///
  /// - Parameter data: serialized data
  /// - Returns: the decoded model
  public static func decodeObject<T: Decodable>(_ jsonObject: Any?) -> T? {
    guard let data = CZHTTPJsonSerializer.jsonData(with: jsonObject) else {
      return nil      
    }
    do {
      let model = try JSONDecoder().decode(T.self, from: data)
      return model
    } catch {
      assertionFailure("Failed to decode data of \(T.self). Error - \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Encode input model into data
  ///
  /// - Parameter model: model to be encoded
  /// - Returns: encoded data
  public static func encode<T: Encodable>(_ model: T?) -> Data? {
    guard let model = model else { return nil }
    do {
      let data = try JSONEncoder().encode(model)
      return data
    } catch {
      assertionFailure("Failed to encode model. Error - \(error.localizedDescription)")
      return nil
    }
  }
}

public extension Encodable {
  /// Transform current obj to dictionary
  var dictionaryVersion: [AnyHashable : Any] {
    do {
      let jsonData = try JSONEncoder().encode(self)
      let dictionaryVersion = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [AnyHashable : Any]
      return dictionaryVersion ?? [:]
    } catch {
      assertionFailure("Failed to encode model to Data. Error - \(error.localizedDescription)")
      return [:]
    }
  }
  
  /// Verify whether current obj equals to other obj
  ///
  /// - Parameter other: the other obj to compare
  /// - Returns: true if equals, false otherwise
  func isEqual(toCodable other: Any) -> Bool {
    guard let other = other as? Encodable else {
      // let selfClass = type(of: self) as? AnyClass,
      // let otherClass = type(of: other) as? AnyClass,
      // NSStringFromClass(selfClass) == NSStringFromClass(otherClass)
      return false
    }
    return (dictionaryVersion as NSDictionary).isEqual(to: other.dictionaryVersion)
  }
  
  /// Description of model, needs to mark `CustomStringConvertible` conformance explicitly
  var description: String {
    return prettyDescription
  }
  
  var prettyDescription: String {
    return dictionaryVersion.prettyDescription
  }
}

// MARK: - NSCopying

public extension Encodable where Self: Decodable {
  func copy(with zone: NSZone?) -> Any  {
    return codableCopy(with: zone)
  }
  
  func codableCopy(with zone: NSZone? = nil) -> Self {
    do {
      let encodedData = try JSONEncoder().encode(self)
      let copy = try JSONDecoder().decode(type(of: self), from: encodedData)
      return copy
    } catch {
      assertionFailure("Failed to copy the object. Error - \(error.localizedDescription)")
      return self
    }
  }
}

