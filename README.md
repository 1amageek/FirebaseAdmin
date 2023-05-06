# Firebase admin for Swift

Firebase admin for Swift is a Swift package that provides a simple interface to interact with the Firebase admin SDK.

This repository includes the [googleapis](https://github.com/googleapis/googleapis) repository as a submodule, which is used to generate the API client code for Firebase.

See: https://github.com/1amageek/FirebaseAPI

# Installation

To install Firebase Admin for Swift using the Swift Package Manager:

```Package.swift
dependencies: [
    .package(url: "https://github.com/1amageek/FirebaseAdmin.git", branch: "main")
]
```

# Usage

Loading a service account
Before you can use Firebase Admin for Swift, you need to load a service account. A service account is a JSON file that contains credentials for accessing your Firebase project. You can create a service account by following the instructions in the Firebase documentation.

To load a service account in your Swift code:

```
func loadServiceAccount(from jsonFile: String) throws -> ServiceAccount {
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

let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
FirebaseApp.initialize(serviceAccount: serviceAccount)
```

```main.swift

struct Object: Codable, Equatable {
    var number: Int = 0
    var string: String = "string"
    var bool: Bool = true
    var array: [String] = ["0", "1"]
    var map: [String: String] = ["value": "value"]
    var date: Date = Date(timeIntervalSince1970: 0)
    var timestamp: Timestamp = Timestamp(seconds: 0, nanos: 0)
    var geoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    var reference: DocumentReference = Firestore.firestore().document("documents/id")
}

let writeData: Object = .init(
    number: 0,
    string: "string",
    bool: true,
    array: ["0", "1"],
    map: ["key": "value"],
    date: Date(timeIntervalSince1970: 0),
    timestamp: Timestamp(seconds: 0, nanos: 0),
    geoPoint: GeoPoint(latitude: 0, longitude: 0),
    reference: Firestore.firestore().document("documents/id")
)

let ref = Firestore
    .firestore()
    .collection("documents")
    .document("your_id")
try await ref.setData(writeData)
let readData = try await ref.getDocument(type: Object.self)

```

## Built-in Support for Timestamp, GeoPoint, and DocumentReference Types

Firebase Admin for Swift provides built-in support for `Timestamp`, `GeoPoint`, and `DocumentReference` types, making it easy to work with these types in your Swift code.

- `Timestamp` represents a point in time, with a precision of up to nanoseconds.
- `GeoPoint` represents a geographical point on the Earth's surface, with latitude and longitude coordinates.
- `DocumentReference` represents a reference to a document in your Firestore database.

With Firebase Admin for Swift, you can create, read, update, and delete documents in your Firestore database using `DocumentReference` objects. You can also store and retrieve timestamps and geographical coordinates using `Timestamp` and `GeoPoint` objects, respectively. Firebase Admin for Swift automatically converts between these Swift types and the corresponding Firestore types.

For example, you can create a `Timestamp` object with the current time using `Timestamp()`, and you can create a `GeoPoint` object with latitude and longitude coordinates using `GeoPoint(latitude:longitude:)`. You can also create a `DocumentReference` object using the `document(_:)` method of a `CollectionReference` object.


Firebase Admin for Swift currently supports read and write operations on documents and collections in your Firestore database. However, it does not yet support transactions, which allow you to execute a sequence of read and write operations as a single, atomic unit of work.

Adding transaction support to Firebase Admin for Swift is on the roadmap, and we plan to add this feature in a future release. With transactions, you'll be able to perform complex read and write operations on your Firestore data with confidence, knowing that the changes will either all succeed or all fail together.

We understand that transactions are an important feature for many developers using Firebase, and we're committed to adding this functionality to Firebase Admin for Swift as soon as possible. 

## Codable Support and Property Wrappers

### Codable
Firebase Admin for Swift provides several convenient features for working with Firestore data, including support for Codable and property wrappers.

With Firebase Admin for Swift's Codable support, you can easily encode and decode Swift objects to and from Firestore documents. To make a Swift object Codable, simply adopt the Codable protocol and define the properties you want to encode and decode. For example:

```User.swift
struct User: Codable {
    var name: String
    var age: Int
}
```

### Property wrappers

Firebase Admin for Swift also supports property wrappers, including @DocumentID and @ExplicitNull. The @DocumentID property wrapper allows you to automatically populate a property with the ID of the document when decoding from Firestore:

```User.swift
struct User: Codable {
    @DocumentID var id: String?
    var name: String
    var age: Int
}
```

One important thing to note is that the @DocumentID property is not saved as a field in the Firestore document. The reason for this is that Firestore already has a reference to the document through the DocumentReference object, so there's no need to store the ID as a separate field.

However, if your User object is nested inside another object, the id property will be saved as a field in the Firestore document for that object. This is because the top-level DocumentReference does not have a reference to the nested User object, so the ID needs to be saved as a field to be able to reference the object later.

The @ExplicitNull property wrapper allows you to set a property to nil in Firestore by explicitly setting it to nil in your Swift object:

```User.swift
struct User: Codable {
    var name: String
    @ExplicitNull var age: Int?
}

```

## Vapor

Here's an example of how to use Firebase Admin for Swift in a Vapor app:

```Package.json

// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "YOUR_SERVER_APP",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/1amageek/FirebaseAdmin.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "FirebaseApp", package: "FirebaseAdmin"),
                .product(name: "Firestore", package: "FirebaseAdmin"),
            ],
            resources: [
                .copy("account_service.json")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
```

# Development

To develop this library, you will need a `ServiceAccount.json` file.

Please copy this file to the `FirestoreTests` directory.

## Development Steps

1. Download the service account key from Firebase Console and save it as `ServiceAccount.json`.

2. Copy the `ServiceAccount.json` file to the `FirestoreTests` directory.

3. Open the project in Xcode and select the `FirestoreTests` target.

```Package.swift
        .testTarget(
            name: "FirestoreTests",
            dependencies: ["Firestore"],
            resources: [
                .copy("ServiceAccount.json")
            ]),
```

