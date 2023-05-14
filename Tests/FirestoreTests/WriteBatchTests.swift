//
//  WriteBatchTests.swift
//  
//
//  Created by Norikazu Muramoto on 2023/05/13.
//

import XCTest
@testable import Firestore

final class WriteBatchTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

    override func tearDown() async throws {
        let snapshot = try await Firestore.firestore().collection("test_batch")
            .getDocuments()
        let batch = Firestore.firestore().batch()
        snapshot.documents.forEach { snapshot in
            batch.deleteDocument(document: snapshot.documentReference)
        }
        try await batch.commit()
    }

    class func loadServiceAccount(from jsonFile: String) throws -> ServiceAccount {
        guard let path = Bundle.module.path(forResource: jsonFile, ofType: "json")  else {
            throw NSError(domain: "FileNotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            let serviceAccount = try decoder.decode(ServiceAccount.self, from: data)
            return serviceAccount
        } catch {
            throw NSError(domain: "JSONParsingError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON file: \(error)"])
        }
    }

    func testCreateWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let batch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_create_\(index)")
            batch.setData(data: ["field": index], forDocument: ref)
        }
        try await batch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_create_\(index)")
            let snapshot = try await ref.getDocument()
            let data = snapshot.data()!
            XCTAssertEqual(data["field"] as! Int, index)
        }
    }

    func testSetDataWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_setData_\(index)")
            createBatch.setData(data: ["count": index, "name": "name"], forDocument: ref)
        }
        try await createBatch.commit()
        let updateBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_setData_\(index)")
            updateBatch.setData(data: ["field": index + 1], forDocument: ref)
        }
        try await updateBatch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_setData_\(index)")
            let snapshot = try await ref.getDocument()
            let data = snapshot.data()!
            XCTAssertEqual(data["field"] as! Int, index + 1)
            XCTAssertNil(data["name"])
        }
    }

    func testSetDataMergeWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_setDataMerge_\(index)")
            createBatch.setData(data: ["count": index, "name": "name"], forDocument: ref)
        }
        try await createBatch.commit()
        let updateBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_setDataMerge_\(index)")
            updateBatch.setData(data: ["field": index + 1], forDocument: ref, merge: true)
        }
        try await updateBatch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_setDataMerge_\(index)")
            let snapshot = try await ref.getDocument()
            let data = snapshot.data()!
            XCTAssertEqual(data["field"] as! Int, index + 1)
            XCTAssertEqual(data["name"] as! String, "name")
        }
    }

    func testUpdateWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_update_\(index)")
            createBatch.setData(data: ["count": index, "name": "name"], forDocument: ref)
        }
        try await createBatch.commit()
        let updateBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_update_\(index)")
            updateBatch.updateData(fields: ["field": index + 1], forDocument: ref)
        }
        try await updateBatch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_update_\(index)")
            let snapshot = try await ref.getDocument()
            let data = snapshot.data()!
            XCTAssertEqual(data["field"] as! Int, index + 1)
            XCTAssertEqual(data["name"] as! String, "name")
        }
    }

    func testDeleteWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_\(index)")
            createBatch.setData(data: ["field": index], forDocument: ref)
        }
        try await createBatch.commit()
        let deleteBatch = firestore.batch()
        (0..<5).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_\(index)")
            deleteBatch.deleteDocument(document: ref)
        }
        try await deleteBatch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_\(index)")
            let snapshot = try await ref.getDocument()
            XCTAssertFalse(snapshot.exists)
        }
    }

    func testLimitMaxWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<501).forEach { index in
            let ref = firestore.collection("test_batch").document("batch_limit_\(index)")
            createBatch.setData(data: ["field": index], forDocument: ref)
        }
        do {
            try await createBatch.commit()
            fatalError()
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testFieldValueWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<5).forEach { index in
            let timestamp = FieldValue.serverTimestamp
            let ref = firestore.collection("test_batch").document("batch_fieldvalue_\(index)")
            createBatch.setData(data: ["field": index, "timestamp": timestamp], forDocument: ref)
        }
        try await createBatch.commit()
        for index in (0..<5) {
            let ref = firestore.collection("test_batch").document("batch_fieldvalue_\(index)")
            let snapshot = try await ref.getDocument()
            let data = snapshot.data()!
            XCTAssertEqual(data["field"] as! Int, index)
            XCTAssertTrue(data["timestamp"] is Timestamp)
        }
    }

    func testLimitMaxWithFieldValueWriteBatch() async throws {
        let firestore = Firestore.firestore()
        let createBatch = firestore.batch()
        (0..<501).forEach { index in
            let timestamp = FieldValue.serverTimestamp
            let ref = firestore.collection("test_batch").document("batch_limit_\(index)")
            createBatch.setData(data: ["field": index, "timestamp": timestamp], forDocument: ref)
        }
        do {
            try await createBatch.commit()
            fatalError()
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
