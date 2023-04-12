//
//  Timestamp.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

public struct Timestamp: Codable, Equatable {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Represents seconds of UTC time since Unix epoch
    /// 1970-01-01T00:00:00Z. Must be from 0001-01-01T00:00:00Z to
    /// 9999-12-31T23:59:59Z inclusive.
    public var seconds: Int64

    /// Non-negative fractions of a second at nanosecond resolution. Negative
    /// second values with fractions must still have non-negative nanos values
    /// that count forward in time. Must be from 0 to 999,999,999
    /// inclusive.
    public var nanos: Int32

    init(seconds: Int64, nanos: Int32) {
        self.seconds = seconds
        self.nanos = nanos
    }

    public static func now() -> Timestamp {
        let date = Date()
        return Timestamp(seconds: Int64(date.timeIntervalSince1970), nanos: 0)
    }
}
