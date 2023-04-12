//
//  QueryPredicate+gRPC.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/10.
//

import Foundation

extension QueryPredicate {


    func makeFilter(database: Database, collectionID: String) -> Google_Firestore_V1_StructuredQuery.Filter? {
        switch self {
            case .or(let predicates):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.compositeFilter = Google_Firestore_V1_StructuredQuery.CompositeFilter.with {
                        $0.op = .or
                        $0.filters = predicates.map({ $0.makeFilter(database: database, collectionID: collectionID)! })
                    }
                }
            case .and(let predicates):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.compositeFilter = Google_Firestore_V1_StructuredQuery.CompositeFilter.with {
                        $0.op = .and
                        $0.filters = predicates.map({ $0.makeFilter(database: database, collectionID: collectionID)! })
                    }
                }
            case .isEqualTo(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    if value is NSNull {
                        $0.unaryFilter = Google_Firestore_V1_StructuredQuery.UnaryFilter.with {
                            $0.op = .isNull
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = field
                            }
                        }
                    } else {
                        $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = field
                            }
                            $0.op = .equal
                            $0.value = DocumentData.getValue(value)!
                        }
                    }
                }
            case .isNotEqualTo(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    if value is NSNull {
                        $0.unaryFilter = Google_Firestore_V1_StructuredQuery.UnaryFilter.with {
                            $0.op = .isNotNull
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = field
                            }
                        }
                    } else {
                        $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                            $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                                $0.fieldPath = field
                            }
                            $0.op = .notEqual
                            $0.value = DocumentData.getValue(value)!
                        }
                    }
                }
            case .isIn(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .in
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isNotIn(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .notIn
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .arrayContains(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .arrayContains
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .arrayContainsAny(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .arrayContainsAny
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isLessThan(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .lessThan
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isGreaterThan(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .greaterThan
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isLessThanOrEqualTo(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .lessThanOrEqual
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isGreaterThanOrEqualTo(let field, let value):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = field
                        }
                        $0.op = .greaterThanOrEqual
                        $0.value = DocumentData.getValue(value)!
                    }
                }
            case .isEqualToDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .equal
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .isNotEqualToDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .notEqual
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .isInDocumentID(let documentIDs):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .in
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.arrayValue = Google_Firestore_V1_ArrayValue.with {
                                $0.values = documentIDs.map { documentID in
                                    Google_Firestore_V1_Value.with {
                                        $0.referenceValue = "\(database.path)/\(documentID)"
                                    }
                                }
                            }
                        }
                    }
                }
            case .isNotInDocumentID(let documentIDs):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .notIn
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.arrayValue = Google_Firestore_V1_ArrayValue.with {
                                $0.values = documentIDs.map { documentID in
                                    Google_Firestore_V1_Value.with {
                                        $0.referenceValue = "\(database.path)/\(documentID)"
                                    }
                                }
                            }
                        }
                    }
                }
            case .arrayContainsDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .arrayContains
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .arrayContainsAnyDocumentID(let documentIDs):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .arrayContainsAny
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.arrayValue = Google_Firestore_V1_ArrayValue.with {
                                $0.values = documentIDs.map { documentID in
                                    Google_Firestore_V1_Value.with {
                                        $0.referenceValue = "\(database.path)/\(documentID)"
                                    }
                                }
                            }
                        }
                    }
                }
            case .isLessThanDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .lessThan
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .isGreaterThanDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .greaterThan
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .isLessThanOrEqualToDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .lessThanOrEqual
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            case .isGreaterThanOrEqualToDocumentID(let documentID):
                return Google_Firestore_V1_StructuredQuery.Filter.with {
                    $0.fieldFilter = Google_Firestore_V1_StructuredQuery.FieldFilter.with {
                        $0.field = Google_Firestore_V1_StructuredQuery.FieldReference.with {
                            $0.fieldPath = "__name__"
                        }
                        $0.op = .greaterThanOrEqual
                        $0.value = Google_Firestore_V1_Value.with {
                            $0.referenceValue = "\(database.path)/\(documentID)"
                        }
                    }
                }
            default: return nil
        }
    }
}
