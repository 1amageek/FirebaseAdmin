//
//  Query+gRPC.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK

extension Query {

    func makeQuery() -> Google_Firestore_V1_StructuredQuery {

        return Google_Firestore_V1_StructuredQuery.with { query in

            query.from = [Google_Firestore_V1_StructuredQuery.CollectionSelector.with {
                $0.collectionID = collectionID
                $0.allDescendants = allDescendants
            }]

            for predicate in self.predicates {

                switch predicate {
                    case .or(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .and(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isEqualTo(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isNotEqualTo(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isIn(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isNotIn(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .arrayContains(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .arrayContainsAny(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isLessThan(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isGreaterThan(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isLessThanOrEqualTo(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isGreaterThanOrEqualTo(_, _):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .orderBy(let field, let ascending):
                        query.orderBy.append(Google_Firestore_V1_StructuredQuery.Order.with {
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = field
                            }
                            $0.direction = ascending ? .ascending : .descending
                        })
                    case .limitTo(let count):
                        query.limit = Google_Protobuf_Int32Value.with {
                            $0.value = Int32(count)
                        }
                    case .limitToLast(let count):
                        query.limit = Google_Protobuf_Int32Value.with {
                            $0.value = Int32(count)
                        }
                        query.orderBy.append(Google_Firestore_V1_StructuredQuery.Order.with {
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = "__name__"
                            }
                            $0.direction = .descending
                        })
                    case .isEqualToDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isNotEqualToDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isInDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isNotInDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .arrayContainsDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .arrayContainsAnyDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isLessThanDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isGreaterThanDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isLessThanOrEqualToDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                    case .isGreaterThanOrEqualToDocumentID(_):
                        query.where = predicate.makeFilter(database: firestore.database, collectionID: collectionID)!
                }
            }
        }
    }

    func getDocuments() async throws -> QuerySnapshot {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreAsyncClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        let request = Google_Firestore_V1_RunQueryRequest.with {
            $0.parent = name
            $0.structuredQuery = makeQuery()
        }
        let call = client.runQuery(request, callOptions: callOptions)
        var documents: [QueryDocumentSnapshot] = []
        for try await response in call {
            if response.hasDocument {
                let documentID = String(name.split(separator: "/").last!)
                let documentReference = DocumentReference(firestore, parentPath: path, documentID: documentID)
                let documentSnapshot = QueryDocumentSnapshot(document: response.document, documentReference: documentReference)
                documents.append(documentSnapshot)
            }
        }
        return QuerySnapshot(documents: documents)
    }
}
