//
//  DocumentData.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation
import SwiftProtobuf

struct DocumentData {

    var data: [String: Any]

    var keys: [String] { Array(data.keys) }

    init(data: [String : Any]) {
        self.data = data
    }

    func getFields() -> Dictionary<String, Google_Firestore_V1_Value> {
        var fields: Dictionary<String, Google_Firestore_V1_Value> = [:]
        for (key, value) in data {
            if let firestoreValue = DocumentData.getValue(value) {
                fields[key] = firestoreValue
            }
        }
        return fields
    }

    static func getValue(_ anyValue: Any) -> Google_Firestore_V1_Value? {
        var value = Google_Firestore_V1_Value()
        if let intValue = anyValue as? Int {
            value.integerValue = Int64(intValue)
        } else if let intValue = anyValue as? Int64 {
            value.integerValue = intValue
        } else if let boolValue = anyValue as? Bool {
            value.booleanValue = boolValue
        } else if let doubleValue = anyValue as? Double {
            value.doubleValue = doubleValue
        } else if let stringValue = anyValue as? String {
            value.stringValue = stringValue
        } else if let dataValue = anyValue as? Data {
            value.bytesValue = dataValue
        } else if let timestampValue = anyValue as? Timestamp {
            value.timestampValue = SwiftProtobuf.Google_Protobuf_Timestamp.with {
                $0.seconds = timestampValue.seconds
                $0.nanos = timestampValue.nanos
            }
        } else if let dateValue = anyValue as? Date {
            value.timestampValue = SwiftProtobuf.Google_Protobuf_Timestamp.with {
                $0.seconds = Int64(dateValue.timeIntervalSince1970)
                $0.nanos = 0
            }
        } else if let geoPointValue = anyValue as? GeoPoint {
            value.geoPointValue = Google_Type_LatLng.with {
                $0.latitude = geoPointValue.latitude
                $0.longitude = geoPointValue.longitude
            }
        } else if let arrayValue = anyValue as? [Any] {
            var firestoreArrayValue = Google_Firestore_V1_ArrayValue()
            firestoreArrayValue.values = arrayValue.compactMap({ DocumentData.getValue($0) })
            value.arrayValue = firestoreArrayValue
        } else if let mapValue = anyValue as? [String: Any] {
            value.mapValue = Google_Firestore_V1_MapValue.with {
                $0.fields = Dictionary(uniqueKeysWithValues: mapValue.compactMap { key, value in
                    if let value = DocumentData.getValue(value) {
                        return (key, value)
                    }
                    return nil
                })
            }
        } else {
            value.nullValue = .nullValue
        }
        return value
    }

    func getFieldTransforms(documentPath: String) -> [Google_Firestore_V1_DocumentTransform.FieldTransform] {
        let fieldValues = getFieldValues(in: data)
        return fieldValuesToFieldTransforms(documentPath: documentPath, fieldValues: fieldValues)
    }

    func getFieldValues(in dictionary: [String: Any], prefix: String? = nil) -> [String: FieldValue] {
        var fieldValues: [String: FieldValue] = [:]
        for (key, value) in dictionary {
            let fullPath = prefix != nil ? "\(prefix!).\(key)" : key

            if let fieldValue = value as? FieldValue {
                fieldValues[fullPath] = fieldValue
            } else if let nestedDict = value as? [String: Any] {
                let nestedFieldValues = getFieldValues(in: nestedDict, prefix: fullPath)
                fieldValues.merge(nestedFieldValues) { (_, new) in new }
            }
        }
        return fieldValues
    }

    func fieldValuesToFieldTransforms(documentPath: String, fieldValues: [String: FieldValue]) -> [Google_Firestore_V1_DocumentTransform.FieldTransform] {
        var fieldTransforms: [Google_Firestore_V1_DocumentTransform.FieldTransform] = []
        for (fieldPath, value) in fieldValues {
            var fieldTransform = Google_Firestore_V1_DocumentTransform.FieldTransform()
            fieldTransform.fieldPath = fieldPath
            switch value {
                case let .arrayUnion(elements):
                    var arrayValue = Google_Firestore_V1_ArrayValue()
                    arrayValue.values = elements.compactMap { DocumentData.getValue($0) }
                    fieldTransform.appendMissingElements = arrayValue
                case let .arrayRemove(elements):
                    var arrayValue = Google_Firestore_V1_ArrayValue()
                    arrayValue.values = elements.compactMap { DocumentData.getValue($0) }
                    fieldTransform.removeAllFromArray = arrayValue
                case let .increment(value):
                    fieldTransform.increment = DocumentData.getValue(value)!
                case .serverTimestamp:
                    fieldTransform.setToServerValue = .requestTime
                case .delete:
                    continue
            }

            fieldTransforms.append(fieldTransform)
        }
        return fieldTransforms
    }
}
