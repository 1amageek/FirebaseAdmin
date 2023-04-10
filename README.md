# Firebase admin for Swift

Firebase admin for Swift is a Swift package that provides a simple interface to interact with the Firebase admin SDK.

This repository includes the [googleapis](https://github.com/googleapis/googleapis) repository as a submodule, which is used to generate the API client code for Firebase.


# Development

To develop this library, you will need a `ServiceAccount.json` file.

Please copy this file to the `FirestoreTests` directory.

## Development Steps

1. Download the service account key from Firebase Console and save it as `ServiceAccount.json`.

2. Copy the `ServiceAccount.json` file to the `FirestoreTests` directory.

3. Open the project in Xcode and select the `FirestoreTests` target.



## Output latest API

```
protoc ./google/firestore/admin/v1/*.proto \
 ./google/firestore/v1/*.proto \
 ./google/api/field_behavior.proto \
 ./google/api/resource.proto \
 ./google/longrunning/operations.proto \
 ./google/rpc/status.proto \
 ./google/type/latlng.proto \
 --swift_out=../Sources/Firestore/Proto \
 --grpc-swift_out=../Sources/Firestore/Proto \
 --swift_opt=Visibility=Public \
 --grpc-swift_opt=Visibility=Public
```
