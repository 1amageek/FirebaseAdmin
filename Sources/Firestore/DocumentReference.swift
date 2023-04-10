//
//  DocumentReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

public struct DocumentReference {

    public var firestore: Firestore

    private var parentPath: String

    public var documentID: String

    public var path: String { "\(parentPath)/\(documentID)".standardized }

    init(_ firestore: Firestore, parentPath: String, documentID: String) {
        self.firestore = firestore
        self.parentPath = parentPath
        self.documentID = documentID
    }

    public var parent: CollectionReference {
        let components = parentPath
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        let parentPath = components.dropLast(1).joined(separator: "/")
        let collectionID = String(components.last!)
        return CollectionReference(firestore, parentPath: parentPath, collectionID: collectionID)
    }

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
