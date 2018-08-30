![CELLULAR](https://www.cellular.de/cellular-logo.png)
[![Build Status](https://travis-ci.com/cellular/localstorage-swift.svg?branch=master)](https://travis-ci.com/cellular/localstorage-swift)
[![codecov](https://codecov.io/gh/cellular/localstorage-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/cellular/localstorage-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CellularLocalStorage.svg)](https://cocoapods.org/pods/CellularLocalStorage)
[![Swift Version](https://img.shields.io/badge/swift-4.1-orange.svg)](https://swift.org)



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
let encoder = NativeEncoder<User>(encoder: JSONEncoder())
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
let decoder = NativeDecoder<User>(decoder: JSONDecoder())
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


## Installation

CellularLocalStorage is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CellularLocalStorage"
```

## License

CellularLocalStorage is released under the MIT license. [See LICENSE](https://github.com/cellular/localstorage-swift/blob/master/LICENSE) for details.
