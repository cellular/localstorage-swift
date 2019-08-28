<!-- markdownlint-disable MD002 MD033 MD041 -->
<h1 align="center">
  <a href="https://cellular.de">
    <img src="./.github/cellular.svg" width="300" max-width="50%">
  </a>
  <br>LocalStorage<br>

<p align="center">
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.1-orange.svg?style=flat" alt="Swift Version">
    </a>
    <a href="http://travis-ci.com/cellular/localstorage-swift/">
        <img src="https://img.shields.io/travis/com/cellular/localstorage-swift.svg" alt="Travis Build">
    </a>
    <a href="https://codecov.io/gh/cellular/localStorage-swift">
        <img src="https://codecov.io/gh/cellular/localStorage-swift/branch/master/graph/badge.svg" alt="Coverage Report">
    </a>
    <a href="https://cocoapods.org/pods/CellularLocalStorage">
        <img src="https://img.shields.io/cocoapods/v/CellularLocalStorage.svg" alt="CocoaPods Compatible">
    </a>    
</p>

<!-- markdownlint-enable MD033 -->

## Example

To run the example project, clone the repo and open Example/Example.xcodproj with Xcode 11+.

#### 1. Choose a model to persist

``` swift
/// Make model Codable to use default Decoder and Encoder
struct User: Codable {

    let name: String

    init(name: String) {
        self.name = name
    }
}

```
#### 2. Create an LocalStorage.Manager instance and register storages

```swift

// Identifies existing Storages. Used internally for easy storage access through LocalStorage.Manager.
enum Identifier: String {
     case user

    // Path to store data to.
    var path: String {
      switch self {
        case .user: return "example.storage.user"
      }
    }
 }

// Storage persisting data to user storage to  key 'path'
let defaultsStorage = UserDefaultsStorage(userDefaults: UserDefaults.standard, path: Identifier.user.path)
// Wrap defaultsStorage with CachedStorage for faster access.
let userStorage = CachedStorage(storage: defaultsStorage)

// Dictionary containing all storages handled by Manager instance
let storages = [Identifier.user.rawValue: userStorage]

// DispatchLock to allow multiple reads but single write operations on storages. It will perform all
// operations on a concurrent DispatchQueue. It is also possible to simply use a NSLock, which may be
// easier to handle due to reduced thread states. On the downside NSLock has a lower performance on read
// operations than a DispatchLock.
let lock = DispatchLock(queue: DispatchQueue(label: "example.queue.storage", attributes: .concurrent))

// Serial queue for async handling. Enables sequential dispatching of completion blocks.
// Needed for required behaviour in example app.
// NOTE: Default Manager(storages: _, lock: _) uses a concurrent queue.
let asyncQueue = DispatchQueue(label: "async.queue")

let manager = Manager(storages: storages, lock: lock, asyncQueue: asyncQueue)
```

#### 3. Save user

```swift

let user = User(name: "Bernd")
let encoder = FoundationEncoder<User>(encoder: JSONEncoder())
// Prefer async access over sync access
// Sync access := manager.append(_, using: _) -> Result<T, Error>
manager.async.append(user, to: Identifier.user.rawValue, using: encoder) { result in
    switch result {
    case .success(let savedUser):
        print("\(savedUser.name)")
    case .failure(let error):
        print(error)
    }
}
```

#### 4. Load stored user list
```swift
let decoder = FoundationDecoder<User>(decoder: JSONDecoder())
// Prefer async access over sync access
// Sync access := manager.all(from: _, using: _) -> Result<[T], Error>
manager.async.all(from: Identifier.user.rawValue, using: decoder) { result in
   switch result {
   case .success(let user):
       user.forEach { print("\($0.name)") }
   case .failure(let error):
       print(error)
   }
}
```
## Requirements
- Swift 5.0+
- iOS 11.0+
- tvOS 11.0+
- watchOS 5.0+

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
  dependencies: [
        .package(url: "https://github.com/cellular/cellular-swift.git", from: "6.0.0")
    ]
```

### [CocoaPods](http://cocoapods.org)

```ruby
pod "CellularLocalStorage"
```

## License

CellularLocalStorage is released under the MIT license. [See LICENSE](https://github.com/cellular/localstorage-swift/blob/master/LICENSE) for details.
