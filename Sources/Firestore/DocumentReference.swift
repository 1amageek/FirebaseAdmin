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

    /// The `Database` instance associated with the document reference.
    var database: Database
    
    /// The parent path of the document reference.
    private var parentPath: String
    
    /// The ID of the document reference.
    public var documentID: String
    
    /// The path of the document reference.
    public var path: String { "\(parentPath)/\(documentID)".normalized }
    
    /**
     Initializes a new `DocumentReference` instance with the specified `Database` instance, parent path, and document ID.
     
     - Parameters:
     - database: The `Database` instance associated with the document reference.
     - parentPath: The parent path of the document reference.
     - documentID: The ID of the document reference.
     */
    init(_ database: Database, parentPath: String, documentID: String) {
        self.database = database
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
        return CollectionReference(database, parentPath: parentPath, collectionID: collectionID)
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
        return CollectionReference(database, parentPath: path, collectionID: collectionID)
    }
}

extension DocumentReference: Hashable {

    public static func == (lhs: DocumentReference, rhs: DocumentReference) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension DocumentReference: Codable {

    enum CodingKeys: CodingKey {
        case database
        case path
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(database.database, forKey: .database)
        try container.encode(path, forKey: .path)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let database = try container.decode(Database.self, forKey: .database)
        let path = try container.decode(String.self, forKey: .path)
        let components = path
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        let documentID = String(components.last!)
        let parentPath = components.dropLast(0).joined(separator: "/")
        self.init(database, parentPath: parentPath, documentID: documentID)
    }
}
