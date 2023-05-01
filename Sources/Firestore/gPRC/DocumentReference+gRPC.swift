//
//  DocumentReference+gRPC.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK

extension DocumentReference {

    public func getDocument() async throws -> DocumentSnapshot {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await getDocument(firestore: firestore, headers: headers)
    }

    public func setData(_ documentData: [String: Any], merge: Bool = false) async throws {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await setData(documentData, merge: merge, firestore: firestore, headers: headers)
    }

    public func updateData(_ fields: [String: Any]) async throws {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await updateData(fields, firestore: firestore, headers: headers)
    }

    public func delete() async throws {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await delete(firestore: firestore, headers: headers)
    }
}
