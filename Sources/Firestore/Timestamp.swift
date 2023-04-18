//
//  Timestamp.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation

/**
 A struct that represents a timestamp.

 Use a `Timestamp` instance to represent a point in time, with second and nanosecond precision.

 A `Timestamp` instance requires a number of seconds since the Unix epoch (1970-01-01T00:00:00Z) and a number of nanoseconds to represent a time.

 You can create a `Timestamp` instance using the `init(seconds:nanos:)` initializer, passing in the number of seconds and nanoseconds.

 You can also create a `Timestamp` instance that represents the current time using the `now()` static method.

 `Timestamp` conforms to `Codable` and `Equatable`.

 */
public struct Timestamp: Codable, Equatable {

    /// The number of seconds since the Unix epoch (1970-01-01T00:00:00Z).
    public var seconds: Int64

    /// The number of nanoseconds within the second. Must be from 0 to 999,999,999 inclusive.
    public var nanos: Int32

    /**
     Initializes a new `Timestamp` instance with the specified number of seconds and nanoseconds.

     - Parameters:
        - seconds: The number of seconds since the Unix epoch (1970-01-01T00:00:00Z).
        - nanos: The number of nanoseconds within the second.
     */
    public init(seconds: Int64, nanos: Int32) {
        self.seconds = seconds
        self.nanos = nanos
    }

    /**
     Returns a `Timestamp` instance that represents the current time.

     - Returns: A `Timestamp` instance that represents the current time.
     */
    public static func now() -> Timestamp {
        let date = Date()
        return Timestamp(seconds: Int64(date.timeIntervalSince1970), nanos: 0)
    }
}
