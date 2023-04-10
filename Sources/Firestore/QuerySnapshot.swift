//
//  QuerySnapshot.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/09.
//

import Foundation

public struct QuerySnapshot {

//    public var metadata: SnapshotMetadata

    public var documents: [QueryDocumentSnapshot]

    public var count: Int { documents.count }

    public var isEmpty: Bool { documents.isEmpty }

    init(response: Google_Firestore_V1_ListDocumentsResponse, collectionReference: CollectionReference) {
        self.documents = response.documents.lazy.map({ document in
            let documentID = String(document.name.split(separator: "/").last!)
            let documentReference = DocumentReference(collectionReference.firestore, parentPath: collectionReference.path, documentID: documentID)
            return QueryDocumentSnapshot(document: document, documentReference: documentReference)
        })
    }

    init(documents: [QueryDocumentSnapshot]) {
        self.documents = documents
    }
}
