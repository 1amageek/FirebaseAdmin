//
//  CollectionReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation


/**
 A struct that represents a reference to a Firestore collection.

 The `CollectionReference` struct provides methods for adding, removing, and querying documents within a Firestore collection. It requires a `Firestore` instance to be initialized, along with the ID of the collection and an optional parent path.
 */
public struct CollectionReference {

    /// The `Firestore` instance associated with the collection reference.
    public var firestore: Firestore

    /// The parent path of the collection reference, if any.
    var parentPath: String?

    /// The ID of the collection reference.
    public var collectionID: String

    /// The path of the collection reference.
    public var path: String {
        if let parentPath {
            return "\(parentPath)/\(collectionID)".standardized
        } else {
            return "\(collectionID)".standardized
        }
    }

    /**
     Initializes a `CollectionReference` instance with the specified Firestore instance, parent path (if any), and collection ID.

     - Parameters:
        - firestore: The `Firestore` instance associated with the collection reference.
        - parentPath: The parent path of the collection reference, if any.
        - collectionID: The ID of the collection reference.
     */
    init(_ firestore: Firestore, parentPath: String?, collectionID: String) {
        self.firestore = firestore
        self.parentPath = parentPath
        self.collectionID = collectionID
    }

    /// The parent collection reference of the collection reference, if any.
    public var parent: CollectionReference? {
        guard let parentPath else { return nil }
        let components = parentPath
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        let path = components.dropLast(1).joined(separator: "/")
        let collectionID = String(components.last!)
        return CollectionReference(firestore, parentPath: path, collectionID: collectionID)
    }

    /**
     Returns a `DocumentReference` instance representing the specified Firestore document.

     - Parameter id: The ID of the document to reference. If not provided, a new document ID will be generated.
     - Returns: A `DocumentReference` instance representing the specified Firestore document.
     - Throws: A `FatalError` if the document ID is empty or the path is invalid.
     */
    public func document(_ id: String = IDGenerator.generate()) -> DocumentReference {
        if id.isEmpty {
            fatalError("Document path cannot be empty.")
        }
        let components = id
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        if components.count.isMultiple(of: 2) {
            fatalError("Invalid path. \(id).")
        }
        return DocumentReference(firestore, parentPath: path, documentID: id)
    }
}
