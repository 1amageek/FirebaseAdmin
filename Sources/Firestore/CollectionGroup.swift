//
//  CollectionGroup.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation


public struct CollectionGroup {

    public var firestore: Firestore

    public var groupID: String

    init(_ firestore: Firestore, groupID: String) {
        self.firestore = firestore
        self.groupID = groupID
    }
}
