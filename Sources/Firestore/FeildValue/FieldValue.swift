//
//  FieldValue.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

public enum FieldValue {
    case delete
    case serverTimestamp
    case arrayUnion([Any])
    case arrayRemove([Any])
    case increment(Double)
}
