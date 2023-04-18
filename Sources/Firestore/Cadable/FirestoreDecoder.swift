//
//  FirestoreDecoder.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/18.
//

import Foundation


public struct FirestoreDecoder {

    var passthroughTypes: [Any.Type]

    public init(passthroughTypes: [Any.Type] = [Date.self, Timestamp.self, GeoPoint.self, DocumentReference.self]) {
        self.passthroughTypes = passthroughTypes
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Any) throws -> T {
        return try T.init(from: _FirestoreDecoder(data: data, passthroughTypes: passthroughTypes))
    }
}


class _FirestoreDecoder: Decoder {

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    var passthroughTypes: [Any.Type]

    var data: Any

    init(data: Any, passthroughTypes: [Any.Type] = []) {
        self.data = data
        self.passthroughTypes = passthroughTypes
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard let data = data as? [String: Any] else {
            throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected keyed container"))
        }
        return KeyedDecodingContainer(_KeyedDecodingContainer(decoder: self, data: data))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let data = data as? [Any] else {
            throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected keyed container"))
        }
        return _UnkeyedDecodingContainer(decoder: self, data: data)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        _SingleValueDecodingContainer(decoder: self, data: data)
    }
}

struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

    var decoder: _FirestoreDecoder

    var codingPath: [CodingKey] = []

    var allKeys: [Key] { data.keys.compactMap { Key(stringValue: $0) } }

    var data: [String: Any]

    func contains(_ key: Key) -> Bool {
        return data[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return data[key.stringValue] is NSNull
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = data[key.stringValue] as? Bool else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Bool"))
        }
        return value
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let value = data[key.stringValue] as? String else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a String"))
        }
        return value
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let value = data[key.stringValue] as? Double else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Double"))
        }
        return value
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let value = data[key.stringValue] as? Float else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Float"))
        }
        return value
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let value = data[key.stringValue] as? Int else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int"))
        }
        return value
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let value = data[key.stringValue] as? Int8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int8"))
        }
        return value
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let value = data[key.stringValue] as? Int16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int16"))
        }
        return value
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let value = data[key.stringValue] as? Int32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int32"))
        }
        return value
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let value = data[key.stringValue] as? Int64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int64"))
        }
        return value
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let value = data[key.stringValue] as? UInt else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt"))
        }
        return value
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let value = data[key.stringValue] as? UInt8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt8"))
        }
        return value
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let value = data[key.stringValue] as? UInt16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt16"))
        }
        return value
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let value = data[key.stringValue] as? UInt32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt32"))
        }
        return value
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let value = data[key.stringValue] as? UInt64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt64"))
        }
        return value
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let value = data[key.stringValue] else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected value of type \(type)"))
        }
        if decoder.passthroughTypes.contains(where: { $0 == type }) {
            return value as! T
        } else {
            let decoder = _FirestoreDecoder(data: value, passthroughTypes: decoder.passthroughTypes)
            return try T(from: decoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard let value = data[key.stringValue] as? [String: Any] else {
            throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected keyed container"))
        }
        let nestedDecoder = _FirestoreDecoder(data: value, passthroughTypes: decoder.passthroughTypes)
        return try nestedDecoder.container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        guard let value = data[key.stringValue] as? [Any] else {
            throw DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected unkeyed container"))
        }
        let nestedDecoder = _FirestoreDecoder(data: value, passthroughTypes: decoder.passthroughTypes)
        return try nestedDecoder.unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        decoder
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        decoder
    }
}

struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {

    var decoder: _FirestoreDecoder

    var codingPath: [CodingKey] = []

    var count: Int? { data.count }

    var isAtEnd: Bool { currentIndex >= data.count }

    var currentIndex: Int = 0

    var data: [Any]

    init(decoder: _FirestoreDecoder, data: [Any]) {
        self.decoder = decoder
        self.data = data
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd, data[currentIndex] is NSNull else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected NSNull"))
        }
        currentIndex += 1
        return true
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !isAtEnd, let value = data[currentIndex] as? Bool else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Bool"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd, let value = data[currentIndex] as? String else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a String"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        guard !isAtEnd, let value = data[currentIndex] as? Double else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Double"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        guard !isAtEnd, let value = data[currentIndex] as? Float else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Float"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        guard !isAtEnd, let value = data[currentIndex] as? Int else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !isAtEnd, let value = data[currentIndex] as? Int8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int8"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !isAtEnd, let value = data[currentIndex] as? Int16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int16"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !isAtEnd, let value = data[currentIndex] as? Int32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int32"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !isAtEnd, let value = data[currentIndex] as? Int64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int64"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !isAtEnd, let value = data[currentIndex] as? UInt else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !isAtEnd, let value = data[currentIndex] as? UInt8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt8"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !isAtEnd, let value = data[currentIndex] as? UInt16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt16"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !isAtEnd, let value = data[currentIndex] as? UInt32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt32"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !isAtEnd, let value = data[currentIndex] as? UInt64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt64"))
        }
        currentIndex += 1
        return value
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected value of type \(type)"))
        }
        let value = data[currentIndex]
        let decoder = _FirestoreDecoder(data: value, passthroughTypes: decoder.passthroughTypes)
        let decodedValue = try T(from: decoder)
        currentIndex += 1
        return decodedValue
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard !isAtEnd, let value = data[currentIndex] as? [String: Any] else {
            throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected unkeyed container"))
        }
        currentIndex += 1
        return KeyedDecodingContainer(_KeyedDecodingContainer(decoder: decoder, data: value))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !isAtEnd, let value = data[currentIndex] as? [Any] else {
            throw DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected unkeyed container"))
        }
        currentIndex += 1
        return _UnkeyedDecodingContainer(decoder: decoder, data: value)
    }

    mutating func superDecoder() throws -> Decoder {
        decoder
    }
}

struct _SingleValueDecodingContainer: SingleValueDecodingContainer {

    var decoder: _FirestoreDecoder

    var codingPath: [CodingKey] = []

    var data: Any

    init(decoder: _FirestoreDecoder, data: Any) {
        self.decoder = decoder
        self.data = data
    }

    func decodeNil() -> Bool { data is NSNull }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let value = data as? Bool else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Bool"))
        }
        return value
    }

    func decode(_ type: String.Type) throws -> String {
        guard let value = data as? String else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a String"))
        }
        return value
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let value = data as? Double else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Double"))
        }
        return value
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard let value = data as? Float else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Float"))
        }
        return value
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let value = data as? Int else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int"))
        }
        return value
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let value = data as? Int8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int8"))
        }
        return value
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let value = data as? Int16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int16"))
        }
        return value
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let value = data as? Int32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int32"))
        }
        return value
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let value = data as? Int64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a Int64"))
        }
        return value
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        guard let value = data as? UInt else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt"))
        }
        return value
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let value = data as? UInt8 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt8"))
        }
        return value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let value = data as? UInt16 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt16"))
        }
        return value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let value = data as? UInt32 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt32"))
        }
        return value
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let value = data as? UInt64 else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected a UInt64"))
        }
        return value
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _FirestoreDecoder(data: data, passthroughTypes: decoder.passthroughTypes)
        return try T(from: decoder)
    }
}
