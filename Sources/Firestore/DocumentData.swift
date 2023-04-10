//
//  DocumentData.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation

extension Dictionary<String, Any> {

    func toFields() -> Dictionary<String, Google_Firestore_V1_Value> {
        var fields: Dictionary<String, Google_Firestore_V1_Value> = [:]
        for (key, value) in self {
            let firestoreValue = documentValue(value)
            fields[key] = firestoreValue
        }
        return fields
    }
}
