//
//  Database.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation

/**
 A struct that represents a Firestore database.

 Use a `Database` instance to specify the ID of a Firestore project and the ID of a database within the project.

 You can access the `path` property to get the root path of the Firestore database, which can be used to perform queries across collections.

 You can also access the `database` property to get the path of the database in the format `projects/{projectID}/databases/{databaseID}`.

 */
struct Database: Codable {

    /// The ID of the Firestore project associated with the database.
    var projectId: String

    /// The ID of the database.
    var databaseId: String = "(default)"

    /**
     Initializes a new `Database` instance with the specified project ID.

     - Parameter projectId: The ID of the Firestore project associated with the database.
     */
    init(projectId: String) {
        self.projectId = projectId
    }

    /// The path of the Firestore database.
    var database: String { "projects/\(projectId)/databases/\(databaseId)" }

    /// The root path of the Firestore database.
    var path: String { "projects/\(projectId)/databases/\(databaseId)/documents" }
}
