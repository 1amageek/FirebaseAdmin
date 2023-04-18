//
//  GeoPoint.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation


/**
 A struct that represents a geographical point.

 Use a `GeoPoint` instance to represent a geographical point, with a latitude and longitude.

 A `GeoPoint` instance requires a latitude and longitude, both represented as `Double` values.

 You can create a `GeoPoint` instance using the `init(latitude:longitude:)` initializer, passing in the latitude and longitude values.

 `GeoPoint` conforms to `Codable` and `Equatable`.

 */
public struct GeoPoint: Codable, Equatable {

    /// The latitude value of the geographical point.
    public var latitude: Double

    /// The longitude value of the geographical point.
    public var longitude: Double

    /**
     Initializes a new `GeoPoint` instance with the specified latitude and longitude values.

     - Parameters:
        - latitude: The latitude value of the geographical point.
        - longitude: The longitude value of the geographical point.
     */
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
