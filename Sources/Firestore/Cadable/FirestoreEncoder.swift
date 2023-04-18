//
//  FirebaseEncoder.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/15.
//

import Foundation


public struct FirestoreEncoder {

    private var encoder: _FirestoreEncoder

    public init(passthroughTypes: [Any.Type] = [Date.self, Timestamp.self, GeoPoint.self, DocumentReference.self]) {
        self.encoder = _FirestoreEncoder(passthroughTypes: passthroughTypes)
    }

    public func encode<T>(_ value: T) throws -> [String: Any] where T : Encodable {
        try value.encode(to: encoder)
        guard let topLevel = encoder.data as? [String: Any] else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unable to encode value to dictionary."))
        }
        return topLevel
    }
}

class _FirestoreEncoder: Encoder {

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    var data: Any? = NSNull()

    var passthroughTypes: [Any.Type]

    init(passthroughTypes: [Any.Type] = []) {
        self.passthroughTypes = passthroughTypes
    }

    lazy var dateForamatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter
    }()

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = FirestoreKeyedEncodingContainer<Key>(encoder: self)
        self.data = container.data
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _FirestoreUnkeyedEncodingContainer(encoder: self)
        self.data = container.data
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = _FirestoreSingleValueEncodingContainer(encoder: self)
        self.data = container.encoder.data
        return container
    }
}

struct _FirestoreUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    var codingPath: [CodingKey] { encoder.codingPath }

    var count: Int { data.count }

    var encoder: _FirestoreEncoder

    var data: [Any] = [] {
        didSet { encoder.data = data }
    }

    mutating func encodeNil() throws {
        data.append(NSNull())
    }

    mutating func encode(_ value: Bool) throws {
        data.append(value)
    }

    mutating func encode(_ value: Int) throws {
        data.append(value)
    }

    mutating func encode(_ value: Int8) throws {
        data.append(value)
    }

    mutating func encode(_ value: Int16) throws {
        data.append(value)
    }

    mutating func encode(_ value: Int32) throws {
        data.append(value)
    }

    mutating func encode(_ value: Int64) throws {
        data.append(value)
    }

    mutating func encode(_ value: UInt) throws {
        data.append(value)
    }

    mutating func encode(_ value: UInt8) throws {
        data.append(value)
    }

    mutating func encode(_ value: UInt16) throws {
        data.append(value)
    }

    mutating func encode(_ value: UInt32) throws {
        data.append(value)
    }

    mutating func encode(_ value: UInt64) throws {
        data.append(value)
    }

    mutating func encode(_ value: Float) throws {
        data.append(value)
    }

    mutating func encode(_ value: Double) throws {
        data.append(value)
    }

    mutating func encode(_ value: String) throws {
        data.append(value)
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        if encoder.passthroughTypes.contains(where: { type(of: value) == $0 }) {
            data.append(value)
        } else {
            let subencoder = _FirestoreEncoder(passthroughTypes: encoder.passthroughTypes)
            subencoder.codingPath = encoder.codingPath
            try value.encode(to: subencoder)
            data.append(subencoder.data ?? NSNull())
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = FirestoreKeyedEncodingContainer<NestedKey>(encoder: encoder)
        data.append(container.data)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let nestedEncoder = _FirestoreEncoder(passthroughTypes: encoder.passthroughTypes)
        nestedEncoder.codingPath = codingPath
        let nestedContainer = _FirestoreUnkeyedEncodingContainer(encoder: nestedEncoder)
        data.append(nestedContainer.data)
        return nestedContainer
    }

    mutating func superEncoder() -> Encoder {
        return encoder
    }
}


struct _FirestoreSingleValueEncodingContainer: SingleValueEncodingContainer {

    var codingPath: [CodingKey] = []

    var encoder: _FirestoreEncoder

    mutating func encodeNil() throws {
        encoder.data = NSNull()
    }

    mutating func encode(_ value: Bool) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Int) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Int8) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Int16) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Int32) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Int64) throws {
        encoder.data = value
    }

    mutating func encode(_ value: UInt) throws {
        encoder.data = value
    }

    mutating func encode(_ value: UInt8) throws {
        encoder.data = value
    }

    mutating func encode(_ value: UInt16) throws {
        encoder.data = value
    }

    mutating func encode(_ value: UInt32) throws {
        encoder.data = value
    }

    mutating func encode(_ value: UInt64) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Float) throws {
        encoder.data = value
    }

    mutating func encode(_ value: Double) throws {
        encoder.data = value
    }

    mutating func encode(_ value: String) throws {
        encoder.data = value
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        if encoder.passthroughTypes.contains(where: { type(of: value) == $0 }) {
            encoder.data = value
        } else {
            let subencoder = _FirestoreEncoder(passthroughTypes: encoder.passthroughTypes)
            try value.encode(to: subencoder)
            encoder.data = subencoder.data
        }
    }
}


struct FirestoreKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {

    typealias Key = K

    var codingPath: [CodingKey] = []

    var encoder: _FirestoreEncoder

    var data: [String: Any] = [:] {
        didSet { encoder.data = data }
    }

    mutating func encodeNil(forKey key: Key) throws {
        data[key.stringValue] = NSNull()
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        data[key.stringValue] = value
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if encoder.passthroughTypes.contains(where: { type(of: value) == $0 }) {
            data[key.stringValue] = value
        } else {
            let subencoder = _FirestoreEncoder(passthroughTypes: encoder.passthroughTypes)
            try value.encode(to: subencoder)
            data[key.stringValue] = subencoder.data
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        codingPath.append(key)
        defer { codingPath.removeLast() }
        let container = FirestoreKeyedEncodingContainer<NestedKey>(encoder: encoder)
        data[key.stringValue] = container.data
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        codingPath.append(key)
        defer { codingPath.removeLast() }
        let unkeyedContainer = _FirestoreUnkeyedEncodingContainer(encoder: encoder)
        data[key.stringValue] = unkeyedContainer.data
        return unkeyedContainer
    }

    mutating func superEncoder() -> Encoder {
        return encoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        return encoder
    }
}
