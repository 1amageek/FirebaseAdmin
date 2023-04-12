//
//  DocumentDataVisitor.swift
//
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation
import SwiftProtobuf

class DocumentDataVisitor: SwiftProtobuf.Visitor {

    var value: Any?

    func visitSingularMessageField<M>(value: M, fieldNumber: Int) throws where M : SwiftProtobuf.Message {
        switch value {
            case let v as Google_Protobuf_Timestamp:
                self.value = Timestamp(seconds: v.seconds, nanos: v.nanos)
            case let v as Google_Type_LatLng:
                self.value = GeoPoint(latitude: v.latitude, longitude: v.longitude)
            case let v as Google_Firestore_V1_Value:
                var nestedVisitor = DocumentDataVisitor()
                try v.traverse(visitor: &nestedVisitor)
                self.value = nestedVisitor.value
            case let v as Google_Firestore_V1_ArrayValue:
                var nestedVisitor = DocumentDataVisitor()
                var array: [Any] = []
                for item in v.values {
                    try item.traverse(visitor: &nestedVisitor)
                    if let value = nestedVisitor.value {
                        array.append(value)
                    }
                }
                self.value = array
            case let v as Google_Firestore_V1_MapValue:
                var nestedVisitor = DocumentDataVisitor()
                var dictionary: [String: Any] = [:]
                for (key, item) in v.fields {
                    try item.traverse(visitor: &nestedVisitor)
                    if let value = nestedVisitor.value {
                        dictionary[key] = value
                    }
                }
                self.value = dictionary
            default:
                break
        }
    }

    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : SwiftProtobuf.MapValueType {
        var dictionary = [KeyType.BaseType: ValueType.BaseType]()
        for (key, val) in value {
            dictionary[key] = val
        }
        self.value = dictionary
    }

    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufEnumMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufEnumMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : SwiftProtobuf.Enum, ValueType.RawValue == Int {
        var dictionary = [KeyType.BaseType: ValueType]()
        for (key, val) in value {
            dictionary[key] = val
        }
        self.value = dictionary
    }

    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufMessageMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufMessageMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : Hashable, ValueType : SwiftProtobuf.Message {
        var dictionary = [KeyType.BaseType: ValueType]()
        for (key, val) in value {
            dictionary[key] = val
        }
        self.value = dictionary
    }

    func visitSingularStringField(value: String, fieldNumber: Int) throws {
        self.value = value
    }

    func visitSingularInt64Field(value: Int64, fieldNumber: Int) throws {
        self.value = Int(value)
    }

    func visitSingularDoubleField(value: Double, fieldNumber: Int) throws {
        self.value = value
    }

    func visitSingularBoolField(value: Bool, fieldNumber: Int) throws {
        self.value = value
    }

    func visitSingularUInt64Field(value: UInt64, fieldNumber: Int) throws {
        self.value = value
    }

    func visitSingularBytesField(value: Data, fieldNumber: Int) throws {
        self.value = value
    }

    func visitSingularEnumField<E>(value: E, fieldNumber: Int) throws where E : SwiftProtobuf.Enum {
        if let v = value as? SwiftProtobuf.Google_Protobuf_NullValue, v == .nullValue {
            self.value = NSNull()
        } else {
            self.value = value
        }
    }

    func visitUnknown(bytes: Data) throws {

    }
}
