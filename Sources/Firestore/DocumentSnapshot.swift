//
//  DocumentSnapshot.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation

public struct DocumentSnapshot: Identifiable {

    public var id: String { documentReference.documentID }

    public var path: String { documentReference.path }

    public var documentReference: DocumentReference

    private var document: Google_Firestore_V1_Document

    init(document: Google_Firestore_V1_Document, documentReference: DocumentReference) {
        self.document = document
        self.documentReference = documentReference
    }

    public func data() -> [String: Any] {
        var visitor = DocumentDataVisitor()
        var data: [String: Any] = [:]
        for (key, value) in document.fields {
            try! value.traverse(visitor: &visitor)
            data[key] = visitor.value
        }
        return data
    }
}

