//
//  CollectionReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation


/**
 A reference to a collection in a Firestore database.

 Use a `CollectionReference` instance to perform CRUD operations on documents within a collection. You can add documents, read documents, update documents, and delete documents within a collection.

 You must specify a `Firestore` instance, the ID of the collection, and an optional parent path to create a `CollectionReference` instance.

 A `CollectionReference` instance also provides a `parent` property that returns the parent collection reference, if any. You can use the parent reference to navigate up the collection hierarchy.

 */
public struct CollectionReference {

    /// The `Database` instance associated with the document reference.
    var database: Database

    /// The parent path of the collection reference, if any.
    var parentPath: String?

    /// The ID of the collection reference.
    public var collectionID: String

    /// The path of the collection reference.
    public var path: String {
        if let parentPath {
            return "\(parentPath)/\(collectionID)".normalized
        } else {
            return "\(collectionID)".normalized
        }
    }

    /**
     Initializes a new `CollectionReference` instance with the specified Firestore instance, parent path (if any), and collection ID.

     - Parameters:
        - database: The `Database` instance associated with the document reference.
        - parentPath: The parent path of the collection reference, if any.
        - collectionID: The ID of the collection reference.
     */
    init(_ database: Database, parentPath: String?, collectionID: String) {
        self.database = database
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
        return CollectionReference(database, parentPath: path, collectionID: collectionID)
    }

    /**
     Returns a `DocumentReference` instance representing the specified Firestore document.

     - Parameter id: The ID of the document to reference. If not provided, a new document ID will be generated.
     - Returns: A `DocumentReference` instance representing the specified Firestore document.
     - Throws: A `FatalError` if the document ID is empty or the path is invalid.
     */
    public func document(_ id: String = IDGenerator.generate()) -> DocumentReference {
        if id.isEmpty {
            fatalError("Document ID cannot be empty.")
        }
        let components = id
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        if components.count.isMultiple(of: 2) {
            fatalError("Invalid document path: \(id).")
        }
        return DocumentReference(database, parentPath: path, documentID: id)
    }
}
