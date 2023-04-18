//
//  CollectionGroup.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

/**
 A group of collections in a Firestore database.

 Use a `CollectionGroup` instance to perform queries across multiple collections that share the same subcollection name.

 For example, consider a database with the following collections:

 - `users/{userID}/posts/{postID}`
 - `groups/{groupID}/posts/{postID}`
 - `companies/{companyID}/employees/{employeeID}/projects/{projectID}/tasks/{taskID}`

 Each collection has a subcollection named `posts`. You can use a `CollectionGroup` instance to query all posts across all collections with the subcollection name `posts`.

 You must specify a `Firestore` instance and a group ID to create a `CollectionGroup` instance.

 */
public struct CollectionGroup {

    /// The Firestore instance associated with the collection group.
    var database: Database

    /// The ID of the collection group.
    public var groupID: String

    /**
     Initializes a new `CollectionGroup` instance with the specified Firestore instance and group ID.

     - Parameters:
        - database: The `Firestore` instance associated with the collection group.
        - groupID: The ID of the collection group.
     */
    init(_ database: Database, groupID: String) {
        self.database = database
        self.groupID = groupID
    }
}
