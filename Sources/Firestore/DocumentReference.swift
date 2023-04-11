//
//  DocumentReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

/**
 A struct that represents a reference to a Firestore document.

 The `DocumentReference` struct provides methods for updating, deleting, and retrieving data for a specific Firestore document. It requires a `Firestore` instance to be initialized, along with the ID of the document and its parent path.
 */
public struct DocumentReference {

    /// The `Firestore` instance associated with the document reference.
    public var firestore: Firestore

    /// The parent path of the document reference.
    private var parentPath: String

    /// The ID of the document reference.
    public var documentID: String

    /// The path of the document reference.
    public var path: String { "\(parentPath)/\(documentID)".standardized }

    /**
     Initializes a `DocumentReference` instance with the specified Firestore instance, parent path, and document ID.

     - Parameters:
        - firestore: The `Firestore` instance associated with the document reference.
        - parentPath: The parent path of the document reference.
        - documentID: The ID of the document reference.
     */
    init(_ firestore: Firestore, parentPath: String, documentID: String) {
        self.firestore = firestore
        self.parentPath = parentPath
        self.documentID = documentID
    }

    /// The parent collection reference of the document reference.
    public var parent: CollectionReference {
        let components = parentPath
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        let parentPath = components.dropLast(1).joined(separator: "/")
        let collectionID = String(components.last!)
        return CollectionReference(firestore, parentPath: parentPath, collectionID: collectionID)
    }

    /**
     Returns a `CollectionReference` instance representing the specified Firestore collection.

     - Parameter collectionID: The ID of the collection to reference.
     - Returns: A `CollectionReference` instance representing the specified Firestore collection.
     - Throws: A `FatalError` if the collection ID is empty or invalid.
     */
    public func collection(_ collectionID: String) -> CollectionReference {
        if collectionID.isEmpty {
            fatalError("Collection ID cannot be empty.")
        }
        let components = collectionID
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        if components.count.isMultiple(of: 2) {
            fatalError("Invalid collection ID. \(collectionID).")
        }
        return CollectionReference(firestore, parentPath: path, collectionID: collectionID)
    }
}
