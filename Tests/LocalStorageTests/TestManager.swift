import XCTest
import LocalStorage
import CELLULAR

class TestManager: XCTestCase {

    let storagePath = "test.storage.manager"
    let userDefaults = UserDefaults.standard
    let userStorageIdentifier = "user.storage"

    override func setUp() {
        super.setUp()

        userDefaults.removeObject(forKey: storagePath)
    }

    private func createManager() -> Manager {
        let lock = DispatchLock(queue: .init(label: "lock.queue", qos: .background, attributes: .concurrent))
        let storage = UserDefaultsStorage(userDefaults: userDefaults, path: storagePath)
        return Manager(storages: [userStorageIdentifier: storage], lock: lock)
    }

    // MARK: Save

    func testAppendObject() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = User(name: "first user")

        switch manager.append(user, to: userStorageIdentifier, using: FoundationEncoder<User>()) {
        case .success(let appendResult):
            XCTAssertTrue(appendResult.name == user.name)
            switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
            case .success(let loadResult) where loadResult.count == 1:
                XCTAssertTrue(loadResult.first?.name == user.name)

            case .success(_):
                XCTFail("Did not persist user")

            case .failure(let error):
                XCTFail(String(describing: error))
            }

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testAppendList() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "first user"), User(name: "second user")]

        switch manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>()) {
        case .success(let appendResult):
            XCTAssertTrue(appendResult.count == 2)
            XCTAssertTrue(user == appendResult)

            switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
            case .success(let loadResult) where loadResult.count == 2:
                XCTAssertTrue(loadResult == appendResult)

            case .success(_):
                XCTFail("Did not persist user list properly")

            case .failure(let error):
                XCTFail(String(describing: error))
            }

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    // MARK: Load

    func testAll() {
        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "first user"), User(name: "second user")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())

        switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
        case .success(let list) where list.count == 2:
            XCTAssertTrue(list == user)

        case .success(_):
            XCTFail("Could not load first object from storage")

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testFirst() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "first user"), User(name: "second user")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())

        switch manager.first(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
        case .success(let first?):
            XCTAssertTrue(first.name == user[0].name)

        case .success(nil):
            XCTFail("Could not load first object from storage")

        case .failure(let error):
            XCTFail(String(describing: error))
        }

        switch manager.first(from: userStorageIdentifier, using: FoundationDecoder<User>(), where: { $0.name == user[1].name }) {
        case .success(let first?):
            XCTAssertTrue(first.name == user[1].name)

        case .success(nil):
            XCTFail("Could not load first object from storage")

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testFilter() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "Hans"), User(name: "Hans"), User(name: "Wurst"), User(name: "Hans")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())

        switch manager.filter(from: userStorageIdentifier, using: FoundationDecoder<User>(), including: { $0.name == "Hans" }) {
        case .success(let filteredUser) where filteredUser.count == 3:
            filteredUser.forEach { XCTAssertTrue( $0.name == "Hans") }

        case .success(_):
            XCTFail("Did not filter list correctly")

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testContains() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "Bernd"), User(name: "Igor"), User(name: "Hans"), User(name: "Karl")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())

        switch manager.contains(userStorageIdentifier, using: FoundationDecoder<User>(), where: { $0.name == "Igor" }) {
        case .success(let contained):
            XCTAssertTrue(contained)

        case .failure(let error):
            XCTFail(String(describing: error))
        }

        switch manager.contains(userStorageIdentifier, using: FoundationDecoder<User>(), where: { $0.name == "Wurst" }) {
        case .success(let contained):
            XCTAssertFalse(contained)

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testLast() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "Bernd"), User(name: "Igor"), User(name: "Hans"), User(name: "Karl")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())


        switch manager.last(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
        case .success(let last):
            XCTAssertTrue(last?.name == user.last?.name)

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    // MARK: Delete

    func testRemove() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let user = [User(name: "Bernd"), User(name: "Igor"), User(name: "Hans"), User(name: "Karl")]
        manager.append(all: user, to: userStorageIdentifier, using: FoundationEncoder<User>())

        let userNameToRemove = user[2].name

        let result = manager.remove(from: userStorageIdentifier,
                                    using: FoundationDecoder<User>(),
                                    encoder: FoundationEncoder<User>(),
                                    where: { $0.name == userNameToRemove })

        switch result {
        case .success(let removedObject):
            XCTAssertTrue(removedObject?.name == userNameToRemove)

            switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
            case .success(let loadResult) where loadResult.count == 3:
                XCTAssertTrue(loadResult[0].name == user[0].name)
                XCTAssertTrue(loadResult[1].name == user[1].name)
                XCTAssertTrue(loadResult[2].name == user[3].name) // second user should have been removed

                XCTAssertFalse(loadResult.contains(where: { $0.name == userNameToRemove }))

            case .success(_):
                XCTFail("Did not persist remove user properly")

            case .failure(let error):
                XCTFail(String(describing: error))
            }

        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testReplace() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let originalList = [User(name: "Bernd"), User(name: "Igor"), User(name: "Hans"), User(name: "Karl")]
        manager.append(all: originalList, to: userStorageIdentifier, using: FoundationEncoder<User>())

        let replaceList = [User(name: "Lorem"), User(name: "Ipsum"), User(name: "Wurst"), User(name: "Rolph")]

        switch manager.replaceAll(in: userStorageIdentifier, with: replaceList, using: FoundationEncoder<User>()) {
        case .success(let successList):
            XCTAssertTrue(replaceList == successList)
            XCTAssertFalse(replaceList == originalList)

            switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
            case .success(let loadResult) where loadResult.count == 4:
                XCTAssertTrue(replaceList == loadResult)

            case .success(_):
                XCTFail("Did not persist replace user properly")

            case .failure(let error):
                XCTFail(String(describing: error))
            }
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }

    func testClear() {

        guard userDefaults.object(forKey: storagePath) == nil else {
            XCTFail("Did not clear data before test")
            return
        }

        let manager = createManager()
        let originalList = [User(name: "Bernd"), User(name: "Igor"), User(name: "Hans"), User(name: "Karl")]
        manager.append(all: originalList, to: userStorageIdentifier, using: FoundationEncoder<User>())

        switch manager.clear(storage: userStorageIdentifier) {
        case .success(let cleared):
            XCTAssertTrue(cleared)

            switch manager.all(from: userStorageIdentifier, using: FoundationDecoder<User>()) {
            case .success(let loadResult):
                XCTAssertTrue(loadResult.count == 0)

            case .failure(let error):
                XCTFail(String(describing: error))
            }
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
}
