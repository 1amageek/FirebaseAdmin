import XCTest
@testable import Firestore

final class RangeQueryTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

    let path = "test/range/items"

    struct CalendarItem: Codable {
        var startTime: Timestamp
        var endTime: Timestamp
    }

    override func setUp() async throws {
        let ref = Firestore.firestore().collection(path)
        let batch = Firestore.firestore().batch()
        let item0 = CalendarItem(
            startTime: .init(year: 2023, month: 4, day: 12),
            endTime: .init(year: 2023, month: 4, day: 14)
        )
        let item1 = CalendarItem(
            startTime: .init(year: 2023, month: 4, day: 13),
            endTime: .init(year: 2023, month: 4, day: 15)
        )
        let item2 = CalendarItem(
            startTime: .init(year: 2023, month: 4, day: 14),
            endTime: .init(year: 2023, month: 4, day: 16)
        )
        let item3 = CalendarItem(
            startTime: .init(year: 2023, month: 4, day: 15),
            endTime: .init(year: 2023, month: 4, day: 17)
        )
        let item4 = CalendarItem(
            startTime: .init(year: 2023, month: 4, day: 16),
            endTime: .init(year: 2023, month: 4, day: 18)
        )
        try batch.setData(from: item0, forDocument: ref.document("0"))
        try batch.setData(from: item1, forDocument: ref.document("1"))
        try batch.setData(from: item2, forDocument: ref.document("2"))
        try batch.setData(from: item3, forDocument: ref.document("3"))
        try batch.setData(from: item4, forDocument: ref.document("4"))
        try await batch.commit()

    }

    override func tearDown() async throws {
        let firestore = Firestore.firestore()
        let collection = firestore.collection(path)
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.documentReference.delete()
        }
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

    func testWhereQueryIsEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isEqualTo: Timestamp(year: 2023, month: 4, day: 12))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 1)
        }
    }

    func testWhereQueryIsNotEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isNotEqualTo: Timestamp(year: 2023, month: 4, day: 12))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 4)
        }
    }

    func testWhereQueryIsLessThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isLessThan: Timestamp(year: 2023, month: 4, day: 14))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 2)
        }
    }

    func testWhereQueryIsLessThanOrEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isLessThanOrEqualTo: Timestamp(year: 2023, month: 4, day: 14))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 3)
        }
    }

    func testWhereQueryIsGreaterThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isGreaterThan: Timestamp(year: 2023, month: 4, day: 13))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 3)
        }
    }

    func testWhereQueryIsGreaterThanOrEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", isGreaterThanOrEqualTo: Timestamp(year: 2023, month: 4, day: 13))
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 4)
        }
    }

    func testWhereQueryIn() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", in: [Timestamp(year: 2023, month: 4, day: 12), Timestamp(year: 2023, month: 4, day: 13)])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 2)
        }
    }

    func testWhereQueryNotIn() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .where(field: "startTime", notIn: [Timestamp(year: 2023, month: 4, day: 12), Timestamp(year: 2023, month: 4, day: 13)])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 3)
        }
    }

    func testWhereQueryAndGreaterThanOrEqualToLessThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .and([
                    ("startTime" >= Timestamp(year: 2023, month: 4, day: 12)),
                    ("startTime" < Timestamp(year: 2023, month: 4, day: 14))
                ])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 2)
        }
    }

    func testWhereQueryAndGreaterThanOrEqualToLessThanOrEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .and([
                    ("startTime" >= Timestamp(year: 2023, month: 4, day: 12)),
                    ("startTime" <= Timestamp(year: 2023, month: 4, day: 14))
                ])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 3)
        }
    }

    func testWhereQueryOrAndGreaterThanOrEqualToLessThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .or([
                    .and([
                        ("startTime" >= Timestamp(year: 2023, month: 4, day: 12)),
                        ("startTime" < Timestamp(year: 2023, month: 4, day: 13))
                    ]),
                    .and([
                        ("startTime" >= Timestamp(year: 2023, month: 4, day: 14)),
                        ("startTime" < Timestamp(year: 2023, month: 4, day: 15))
                    ])
                ])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 2)
        }
    }

    func testWhereQueryOrAndGreaterThanOrEqualToLessThanOrEqualToo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref
                .or([
                    .and([
                        ("startTime" >= Timestamp(year: 2023, month: 4, day: 12)),
                        ("startTime" <= Timestamp(year: 2023, month: 4, day: 13))
                    ]),
                    .and([
                        ("startTime" >= Timestamp(year: 2023, month: 4, day: 14)),
                        ("startTime" <= Timestamp(year: 2023, month: 4, day: 15))
                    ])
                ])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 4)
        }
    }
}
