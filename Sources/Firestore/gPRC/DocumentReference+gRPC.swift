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

    var name: String {
        return "\(firestore.database.path)/\(path)".standardized
    }

    func getDocument() async throws -> DocumentSnapshot {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreNIOClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        let request = Google_Firestore_V1_GetDocumentRequest.with {
            $0.name = name
        }
        let call = client.getDocument(request, callOptions: callOptions)
        let document = try await call.response.get()
        return DocumentSnapshot(document: document, documentReference: self)
    }

    @discardableResult
    func setData(_ documentData: [String: Any], merge: Bool = false) async throws -> DocumentSnapshot {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreNIOClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        if merge {
            let updateMaskFieldPaths: [String] = Array(documentData.keys)
            let request = Google_Firestore_V1_UpdateDocumentRequest.with {
                $0.document = Google_Firestore_V1_Document.with {
                    $0.name = name
                    $0.fields = documentData.toFields()
                }
                $0.updateMask = Google_Firestore_V1_DocumentMask.with {
                    $0.fieldPaths = updateMaskFieldPaths
                }
            }
            let call = client.updateDocument(request, callOptions: callOptions)
            let document = try await call.response.get()
            return DocumentSnapshot(document: document, documentReference: self)
        } else {
            let request = Google_Firestore_V1_CreateDocumentRequest.with {
                $0.parent = parent.name
                $0.collectionID = parent.collectionID
                $0.documentID = documentID
                $0.document = Google_Firestore_V1_Document.with {
                    $0.fields = documentData.toFields()
                }
            }
            let call = client.createDocument(request, callOptions: callOptions)
            let document = try await call.response.get()
            return DocumentSnapshot(document: document, documentReference: self)
        }
    }

    @discardableResult
    func updateData(_ fields: [String: Any]) async throws -> DocumentSnapshot {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreNIOClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        let updateMaskFieldPaths: [String] = Array(fields.keys)
        let request = Google_Firestore_V1_UpdateDocumentRequest.with {
            $0.document = Google_Firestore_V1_Document.with {
                $0.name = name
                $0.fields = fields.toFields()
            }
            $0.updateMask = Google_Firestore_V1_DocumentMask.with {
                $0.fieldPaths = updateMaskFieldPaths
            }
        }
        let call = client.updateDocument(request, callOptions: callOptions)
        let document = try await call.response.get()
        return DocumentSnapshot(document: document, documentReference: self)
    }

    func delete() async throws {
        let accessToken = try await Firestore.firestore().getAccessToken()
        let client = Google_Firestore_V1_FirestoreNIOClient(channel: firestore.channel)
        let headers = HPACKHeaders([("authorization", "Bearer \(accessToken)")])
        let callOptions = CallOptions(customMetadata: headers)
        let request = Google_Firestore_V1_DeleteDocumentRequest.with {
            $0.name = name
        }
        let call = client.deleteDocument(request, callOptions: callOptions)
        _ = try await call.response.get()
    }
}
