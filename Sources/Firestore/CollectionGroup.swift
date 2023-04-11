//
//  CollectionGroup.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

/**
 A struct that represents a Firestore collection group.

 The `CollectionGroup` struct provides methods for querying documents across all collections with the same ID. It requires a `Firestore` instance to be initialized.
 */
public struct CollectionGroup {

    /// The `Firestore` instance associated with the collection group.
    public var firestore: Firestore

    /// The ID of the collection group.
    public var groupID: String

    /**
     Initializes a `CollectionGroup` instance with the specified Firestore instance and group ID.

     - Parameters:
        - firestore: The `Firestore` instance associated with the collection group.
        - groupID: The ID of the collection group.
     */
    init(_ firestore: Firestore, groupID: String) {
        self.firestore = firestore
        self.groupID = groupID
    }
}
