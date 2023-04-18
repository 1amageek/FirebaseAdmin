//
//  Query.swift
//
//
//  Created by nori on 2022/05/16.
//

import Foundation

/**
 A struct that represents a query against a Firestore database.

 Use a `Query` instance to retrieve a subset of documents from a collection that meet certain criteria, such as filtering by field values or ordering by a specified field.

 A `Query` instance requires a `Database` instance, the ID of the collection, and an optional parent path.

 A query may also include optional filters, sorts, and limits to further refine the results.

 */
public struct Query {

    /// The `Database` instance associated with the query.
    var database: Database

    /// The parent path of the query, if any.
    var parentPath: String?

    /// The ID of the collection being queried.
    public var collectionID: String

    /// A flag that indicates whether the query should include all descendants of the collection.
    var allDescendants: Bool

    /// An array of query predicates used to filter and order the results of the query.
    var predicates: [QueryPredicate]

    /// The path of the collection being queried.
    public var path: String {
        if let parentPath {
            return "\(parentPath)/\(collectionID)".normalized
        } else {
            return "\(collectionID)".normalized
        }
    }

    /**
     Initializes a new `Query` instance with the specified `Database` instance, parent path, collection ID, and query parameters.

     - Parameters:
        - database: The `Database` instance associated with the query.
        - parentPath: The parent path of the query, if any.
        - collectionID: The ID of the collection being queried.
        - allDescendants: A flag that indicates whether the query should include all descendants of the collection. The default value is `false`.
        - predicates: An array of `QueryPredicate` instances used to filter and order the results of the query.
     */
    init(_ database: Database, parentPath: String?, collectionID: String, allDescendants: Bool = false, predicates: [QueryPredicate]) {
        self.database = database
        self.parentPath = parentPath
        self.allDescendants = allDescendants
        self.collectionID = collectionID
        self.predicates = predicates
    }
}

extension Query {
    
    var name: String {
        if let parentPath {
            return "\(database.path)/\(parentPath)".normalized
        }
        return "\(database.path)".normalized
    }
}

// MARK: CompositeFilter
extension Query {

    public func or(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.or(filters))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func and(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.and(filters))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

// MARK: Filter
extension Query {

    func append(_ predicate: QueryPredicate) -> [QueryPredicate] {
        var predicates = self.predicates
        if let compositeFilter = predicates.first(where: { $0.type == .compositeFilter }) {
            if case .and(let filters) = compositeFilter {
                let index = predicates.firstIndex(where: { $0.type == .compositeFilter })!
                var newFilters = filters
                newFilters.append(predicate)
                predicates[index] = .and(newFilters)
                return predicates
            }
            if case .or(_) = compositeFilter {
                let index = predicates.firstIndex(where: { $0.type == .compositeFilter })!
                predicates[index] = .and([compositeFilter, predicate])
                return predicates
            }
        } else if let filter = predicates.first(where: { $0.type == .fieldFilter || $0.type == .unaryFilter }) {
            return [.and([filter, predicate])]
        }
        return predicates
    }

    public func `where`(field: String, isEqualTo value: Any) -> Self {
        let predicates = append(.isEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, isNotEqualTo value: Any) -> Self {
        let predicates = append(.isNotEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, isLessThan value: Any) -> Self {
        let predicates = append(.isLessThan(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, isLessThanOrEqualTo value: Any) -> Self {
        let predicates = append(.isLessThanOrEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, isGreaterThan value: Any) -> Self {
        let predicates = append(.isGreaterThan(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, isGreaterThanOrEqualTo value: Any) -> Self {
        let predicates = append(.isGreaterThanOrEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, arrayContains value: Any) -> Self {
        let predicates = append(.arrayContains(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, arrayContainsAny value: [Any]) -> Self {
        let predicates = append(.arrayContainsAny(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, in value: [Any]) -> Self {
        let predicates = append(.isIn(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(field: String, notIn value: [Any]) -> Self {
        let predicates = append(.isNotIn(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    // DocumentID
    public func `where`(isEqualTo value: String) -> Self {
        let predicates = append(.isEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(isNotEqualTo value: String) -> Self {
        let predicates = append(.isNotEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(isLessThan value: String) -> Self {
        let predicates = append(.isLessThanDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(isLessThanOrEqualTo value: String) -> Self {
        let predicates = append(.isLessThanOrEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(isGreaterThan value: String) -> Self {
        let predicates = append(.isGreaterThanDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(isGreaterThanOrEqualTo value: String) -> Self {
        let predicates = append(.isGreaterThanOrEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(arrayContains value: String) -> Self {
        let predicates = append(.arrayContainsDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(arrayContainsAny value: [String]) -> Self {
        let predicates = append(.arrayContainsAnyDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(in value: [String]) -> Self {
        let predicates = append(.isInDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func `where`(notIn value: [String]) -> Self {
        let predicates = append(.isNotInDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

// MARK: Limit
extension Query {

    public func limit(to value: Int) -> Self {
        var predicates = self.predicates
        predicates.append(.limitTo(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    public func limit(toLast value: Int) -> Self {
        var predicates = self.predicates
        predicates.append(.limitToLast(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

// MARK: Order
extension Query {

    public func order(by field: String, descending value: Bool) -> Self {
        var predicates = self.predicates
        predicates.append(.orderBy(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

extension KeyedEncodingContainer where Key : CodingKey {

    fileprivate mutating func encode(_ value: Any, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let value = value as? Bool {
            try encode(value, forKey: key)
        } else if let value = value as? String {
            try encode(value, forKey: key)
        } else if let value = value as? Double {
            try encode(value, forKey: key)
        } else if let value = value as? Float {
            try encode(value, forKey: key)
        } else if let value = value as? Int {
            try encode(value, forKey: key)
        } else if let value = value as? Int8 {
            try encode(value, forKey: key)
        } else if let value = value as? Int16 {
            try encode(value, forKey: key)
        } else if let value = value as? Int32 {
            try encode(value, forKey: key)
        } else if let value = value as? Int64 {
            try encode(value, forKey: key)
        } else if let value = value as? UInt {
            try encode(value, forKey: key)
        } else if let value = value as? UInt8 {
            try encode(value, forKey: key)
        } else if let value = value as? UInt16 {
            try encode(value, forKey: key)
        } else if let value = value as? UInt32 {
            try encode(value, forKey: key)
        } else if let value = value as? UInt64 {
            try encode(value, forKey: key)
        }
    }

    fileprivate mutating func encode(_ value: [Any], forKey key: KeyedEncodingContainer<K>.Key) throws {
        if let value = value as? [Bool] {
            try encode(value, forKey: key)
        } else if let value = value as? [String] {
            try encode(value, forKey: key)
        } else if let value = value as? [Double] {
            try encode(value, forKey: key)
        } else if let value = value as? [Float] {
            try encode(value, forKey: key)
        } else if let value = value as? [Int] {
            try encode(value, forKey: key)
        } else if let value = value as? [Int8] {
            try encode(value, forKey: key)
        } else if let value = value as? [Int16] {
            try encode(value, forKey: key)
        } else if let value = value as? [Int32] {
            try encode(value, forKey: key)
        } else if let value = value as? [Int64] {
            try encode(value, forKey: key)
        } else if let value = value as? [UInt] {
            try encode(value, forKey: key)
        } else if let value = value as? [UInt8] {
            try encode(value, forKey: key)
        } else if let value = value as? [UInt16] {
            try encode(value, forKey: key)
        } else if let value = value as? [UInt32] {
            try encode(value, forKey: key)
        } else if let value = value as? [UInt64] {
            try encode(value, forKey: key)
        }
    }
}
