//
//  CollectionReference+gRPC.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK

extension CollectionReference {

    var name: String {
        if let parentPath {
            return "\(firestore.database.path)/\(parentPath)".normalized
        }
        return "\(firestore.database.path)".normalized
    }

    public func getDocuments() async throws -> QuerySnapshot {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreNIOClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        let request = Google_Firestore_V1_ListDocumentsRequest.with {
            $0.parent = name
            $0.collectionID = collectionID
        }
        let call = client.listDocuments(request, callOptions: callOptions)
        let response: Google_Firestore_V1_ListDocumentsResponse = try await call.response.get()
        return QuerySnapshot(response: response, collectionReference: self)
    }
}
