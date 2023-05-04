//
//  Query+gRPC.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation
import NIOHPACK

extension Query {

    public func getDocuments<T: Decodable>(type: T.Type) async throws -> [T] {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await getDocuments(type: type, firestore: firestore, headers: headers)
    }
    public func getDocuments() async throws -> QuerySnapshot {
        let firestore = Firestore.firestore()
        let accessToken = try await firestore.getAccessToken()
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        return try await getDocuments(firestore: firestore, headers: headers)
    }
}
