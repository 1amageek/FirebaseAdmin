//
//  Database.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation

struct Database {

    var projectId: String

    var databaseId: String = "(default)"

    init(projectId: String) {
        self.projectId = projectId
    }

    var path: String { "projects/\(projectId)/databases/\(databaseId)/documents" }
}
