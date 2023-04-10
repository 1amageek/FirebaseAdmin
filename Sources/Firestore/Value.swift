//
//  File.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation
import SwiftProtobuf

func documentValue(_ anyValue: Any) -> Google_Firestore_V1_Value {
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
    } else if let timestampValue = anyValue as? SwiftProtobuf.Google_Protobuf_Timestamp {
        value.timestampValue = timestampValue
    } else if let geoPointValue = anyValue as? Google_Type_LatLng {
        value.geoPointValue = geoPointValue
    } else if let arrayValue = anyValue as? [Any] {
        var firestoreArrayValue = Google_Firestore_V1_ArrayValue()
        firestoreArrayValue.values = arrayValue.map({ documentValue($0) })
        value.arrayValue = firestoreArrayValue
    } else if let mapValue = anyValue as? [String: Any] {
        var firestoreMapValue = Google_Firestore_V1_MapValue()
        firestoreMapValue.fields = Dictionary(uniqueKeysWithValues: mapValue.map { key, value in (key, documentValue(value)) })
        value.mapValue = firestoreMapValue
    } else {
        value.nullValue = .nullValue
    }
    return value
}
