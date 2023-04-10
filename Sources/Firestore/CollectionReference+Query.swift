//
//  CollectionReference.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation

extension CollectionReference {

    public func `where`(field: String, isEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isEqualTo(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, isNotEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isNotEqualTo(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, isLessThan value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isLessThan(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, isLessThanOrEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isLessThanOrEqualTo(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, isGreaterThan value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isGreaterThan(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, isGreaterThanOrEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isGreaterThanOrEqualTo(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, arrayContains value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.arrayContains(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, arrayContainsAny value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.arrayContainsAny(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, in value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isIn(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(field: String, notIn value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isNotIn(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func limit(to value: Int) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.limitTo(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func limit(toLast value: Int) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.limitToLast(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func order(by field: String, descending value: Bool) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.orderBy(field, value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func or(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.or(filters))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func and(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.and(filters))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    // DocumentID

    public func `where`(isEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isEqualToDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(isNotEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isNotEqualToDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(isLessThan value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isLessThanDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(isLessThanOrEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isLessThanOrEqualToDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(isGreaterThan value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isGreaterThanDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(isGreaterThanOrEqualTo value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isGreaterThanOrEqualToDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(arrayContains value: Any) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.arrayContainsDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(arrayContainsAny value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.arrayContainsAnyDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(in value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isInDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }

    public func `where`(notIn value: [Any]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.isNotInDocumentID(value))
        return .init(firestore, parentPath: parentPath, collectionID: collectionID, predicates: predicates)
    }
}
