//
//  GeoPoint.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/11.
//

import Foundation


public struct GeoPoint: Codable, Equatable {

    public var latitude: Double

    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
