//
//  FieldValue.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

/**
 An enum that represents a value that can be set in a Firestore document field.

 Use a `FieldValue` instance to represent a special value that can be set in a Firestore document field.

 A `FieldValue` instance can represent several types of values:

 - `delete`: A value that indicates the document field should be deleted.
 - `serverTimestamp`: A value that indicates the document field should be set to the server timestamp.
 - `arrayUnion`: An array value that should be merged with any existing array value in the document field, without creating duplicates.
 - `arrayRemove`: An array value that should be removed from any existing array value in the document field.
 - `increment`: A numeric value that should be added to the existing value in the document field.

 */
public enum FieldValue {

    /// A value that indicates the document field should be deleted.
    case delete

    /// A value that indicates the document field should be set to the server timestamp.
    case serverTimestamp

    /// An array value that should be merged with any existing array value in the document field, without creating duplicates.
    case arrayUnion([Any])

    /// An array value that should be removed from any existing array value in the document field.
    case arrayRemove([Any])

    /// A numeric value that should be added to the existing value in the document field.
    case increment(Double)
}
