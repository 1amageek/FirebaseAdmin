//
//  CollectionReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

public struct CollectionReference {

    public var firestore: Firestore

    var parentPath: String?

    public var collectionID: String

    public var path: String {
        if let parentPath {
            return "\(parentPath)/\(collectionID)".standardized
        } else {
            return "\(collectionID)".standardized
        }
    }

    init(_ firestore: Firestore, parentPath: String?, collectionID: String) {
        self.firestore = firestore
        self.parentPath = parentPath
        self.collectionID = collectionID
    }

    public var parent: CollectionReference? {
        guard let parentPath else { return nil }
        let components = parentPath
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        let path = components.dropLast(1).joined(separator: "/")
        let collectionID = String(components.last!)
        return CollectionReference(firestore, parentPath: path, collectionID: collectionID)
    }

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

