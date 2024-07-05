//
//  MessagesPayload.swift
//
//
//  Created by Vamsi Madduluri on 05/07/24.
//

import Foundation

public struct FcmNotification: Codable {
    public let title: String?
    public let body: String?
    public let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case imageURL = "image"
    }
    
    public init(
        title: String? = nil,
        body: String? = nil,
        imageURL: String? = nil
    ) {
        self.title = title
        self.body = body
        self.imageURL = imageURL
    }
}

public struct AndroidConfig: Codable {
    public let collapseKey: String?
    public let priority: String?
    public let restrictedPackageName: String?
    public let data: [String: String]?
    public let notification: AndroidNotification?
    
    enum CodingKeys: String, CodingKey {
        case collapseKey = "collapse_key"
        case priority
        case restrictedPackageName = "restricted_package_name"
        case data
        case notification
    }
    
    public init(
        collapseKey: String? = nil,
        priority: String? = nil,
        restrictedPackageName: String? = nil,
        data: [String: String]? = nil,
        notification: AndroidNotification? = nil
    ) {
        self.collapseKey = collapseKey
        self.priority = priority
        self.restrictedPackageName = restrictedPackageName
        self.data = data
        self.notification = notification
    }
}

public struct AndroidNotification: Codable {
    public var clickAction: String
    
    enum CodingKeys: String, CodingKey {
        case clickAction = "click_action"
    }
    
    public init(clickAction : String) {
        self.clickAction = clickAction
    }
}

struct WebpushFCMOptions: Codable {
    public let link: String?
    
    enum CodingKeys: String, CodingKey {
        case link
    }
    
    public init(link: String? = nil) {
        self.link = link
    }
}

public struct FCMOptions: Codable {
    public let analyticsLabel: String?
    
    enum CodingKeys: String, CodingKey {
        case analyticsLabel = "analytics_label"
    }
    
    public init(analyticsLabel: String? = nil) {
        self.analyticsLabel = analyticsLabel
    }
}

public struct FcmMessage: Codable {
    public let data: [String: String]?
    public let notification: FcmNotification?
    public let android: AndroidConfig?
    public let fcmOptions: FCMOptions?
    public let token: String?
    public let topic: String?
    public let condition: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case notification
        case android
        case fcmOptions = "fcm_options"
        case token
        case topic
        case condition
    }
    
    public init(
        data: [String: String]? = nil,
        notification: FcmNotification? = nil,
        android: AndroidConfig? = nil,
        fcmOptions: FCMOptions? = nil,
        token: String? = nil,
        topic: String? = nil,
        condition: String? = nil
    ) {
        self.data = data
        self.notification = notification
        self.android = android
        self.fcmOptions = fcmOptions
        self.token = token
        self.topic = topic
        self.condition = condition
    }
}

public struct SendResponse: Codable {
    public var success: Bool
    public var messageID: String
    public var error: String?
    private enum CodingKeys: String, CodingKey {
        case success
        case messageID = "messageID"
        case error
    }
}

struct FcmRequest: Codable {
    public var validateOnly: Bool
    public var message: FcmMessage
    
    private enum CodingKeys: String, CodingKey {
        case validateOnly = "validateOnly"
        case message = "message"
    }
}
