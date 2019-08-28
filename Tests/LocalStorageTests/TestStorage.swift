import UIKit
import XCTest
import LocalStorage

class TestStorage: XCTestCase {

    let userDefaultsPath = "test.storage"
    let userDefaults = UserDefaults.standard

    override func setUp() {
        super.setUp()

        userDefaults.removeObject(forKey: userDefaultsPath)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Tests all operations on UserDefaultsStorage
    func testUserDefaultsStorage() {
        test(storage: UserDefaultsStorage(userDefaults: userDefaults, path: userDefaultsPath))
    }

    // Tests all operations on CachedStorage based on a UserDefaultsStorage
    func testCachedUserDefaultsStorage() {
        let userDefaultsStorage = UserDefaultsStorage(userDefaults: userDefaults, path: userDefaultsPath)
        test(storage: CachedStorage(storage: userDefaultsStorage))
    }

    func testMemoryStory() {
        test(storage: MemoryStorage())
    }

    func testFileStorage() {
        do {
            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "test/cache",
                                          searchPathDirectory: .cashes,
                                          isExcludedFromBackup: false))

            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "",
                                          searchPathDirectory: .cashes,
                                          isExcludedFromBackup: false))

            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "test/documents",
                                          searchPathDirectory: .documents,
                                          isExcludedFromBackup: false))

            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "",
                                          searchPathDirectory: .documents,
                                          isExcludedFromBackup: false))

            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "test/library",
                                          searchPathDirectory: .library,
                                          isExcludedFromBackup: false))

            try test(storage: FileStorage(fileManager: .default,
                                          relativePath: "",
                                          searchPathDirectory: .library,
                                          isExcludedFromBackup: false))

        } catch let error {
            XCTFail("An error occured creating file storages: \(error)")
        }

    }

    /// Helper function to test any storage instance.
    ///
    /// - Parameter storage: Storage to be tested.
    func test(storage: Storage) {
        do {

            let firstUser = User(name: "Karl")

            let encoder = FoundationEncoder<User>()
            let decoder = FoundationDecoder<User>()

            // Clear storage before actual test
            try storage.clear()

            // Save single object to UserDefaultsStorage
            try storage.append(firstUser, using: encoder)


            // Load single model from storage
            let firstModel = try storage.first(using: decoder)
            let firstModelClosure = try storage.first(using: decoder) { $0.name == firstUser.name }
            XCTAssert(firstModel != nil, "Could not load first user from storage")
            XCTAssert(firstModelClosure != nil && firstModelClosure?.name == firstUser.name,
                      "Could not load user \(firstUser.name) from storage")

            // Save second user to storage
            let secondUser = User(name: "John")
            try storage.append(secondUser, using: encoder)

            // Check if last user equals second user
            XCTAssertTrue(try storage.last(using: decoder)?.name == secondUser.name)
            // Check if second user can be found via contains()
            XCTAssertTrue(try storage.contains(using: decoder, where: { $0.name == secondUser.name }))

            // Load all users from storage
            var storedModels = try storage.all(using: decoder)
            XCTAssert(storedModels.count == 2, "Could not load all from storage")

            // Remove John from storage
            let removedUser = try storage.remove(using: decoder, encoder: encoder) { $0.name == secondUser.name }
            XCTAssert(removedUser != nil && removedUser?.name == secondUser.name,
                      "Wrong user \(String(describing: removedUser)) was deleted from storage")
            storedModels = try storage.all(using: decoder)
            XCTAssert(storedModels.count == 1, "Wrong storage count after remove operation")

            let thirdUser = User(name: "Peter")
            let secondAndThirdUser = [secondUser, thirdUser]

            // Append items to storage
            try storage.append(all: secondAndThirdUser, using: encoder)
            storedModels = try storage.all(using: decoder)
            let saveAllCondition = storedModels.count == 3 &&
                storedModels.contains(where: { $0.name == secondUser.name }) &&
                storedModels.contains(where: { $0.name == thirdUser.name }) &&
                storedModels.contains(where: { $0.name == firstUser.name })

            XCTAssert(saveAllCondition, "Could not save and append list of objects to storage.")


            // Replace items from storage
            try storage.replaceAll(with: secondAndThirdUser, using: encoder)
            storedModels = try storage.all(using: decoder)
            let replacementCondition = storedModels.count == 2 &&
                storedModels.contains(where: { $0.name == secondUser.name}) &&
                storedModels.contains(where: { $0.name == thirdUser.name }) &&
                !storedModels.contains(where: { $0.name == firstUser.name })

            XCTAssert(replacementCondition, "incorrtely replaced stored content from storage")

        } catch let error {
            
            XCTFail("Error trying to save or load model: \(error)")
        }
    }

    func testPermanencyForUserDefaultsStorage() {
        do {
            try testPermanentStorage { UserDefaultsStorage(userDefaults: .standard, path: "permanency.test.storgae") }

        } catch let error {
            XCTFail("Error trying to test permanent user default storage: \(error)")
        }
    }

    func testPermanencyForFileStorage() {
        do {
            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "test/cache",
                                searchPathDirectory: .cashes,
                                isExcludedFromBackup: false)
            }

            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "",
                                searchPathDirectory: .cashes,
                                isExcludedFromBackup: false)
            }

            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "test/documents",
                                searchPathDirectory: .documents,
                                isExcludedFromBackup: false)
            }

            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "",
                                searchPathDirectory: .documents,
                                isExcludedFromBackup: false)
            }

            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "test/library",
                                searchPathDirectory: .library,
                                isExcludedFromBackup: false)
            }

            try testPermanentStorage {
                try FileStorage(fileManager: .default,
                                relativePath: "",
                                searchPathDirectory: .library,
                                isExcludedFromBackup: false)
            }

        } catch let error {
            XCTFail("Error trying to test permanent file storage: \(error)")
        }
    }

    func testRelativePath() {
        do {
            let relativePath = "test/relativePath/"
            let fileStorage = try FileStorage(fileManager: .default,
                                              relativePath: relativePath,
                                              searchPathDirectory: .library,
                                              isExcludedFromBackup: false)
            XCTAssertTrue(fileStorage.path.contains(relativePath), "Was not able to create relative path -  \(relativePath) - correctly")

        } catch let error {
            XCTFail("Error trying to test relative path creation: \(error)")
        }
    }

    func testBackupValue() {
        do {
            let storageDisabled = try FileStorage(fileManager: .default,
                                                  relativePath: "test/disabled/backup",
                                                  searchPathDirectory: .library,
                                                  isExcludedFromBackup: false)

            let resourceValuesDisabled = try URL(fileURLWithPath: storageDisabled.path, isDirectory: false)
                .resourceValues(forKeys: [.isExcludedFromBackupKey])
            XCTAssertFalse(resourceValuesDisabled.isExcludedFromBackup == true, "Resource value 'Exclude from Backup' was not set to false")
            try storageDisabled.delete()

            let storageEnabled = try FileStorage(fileManager: .default,
                                                 relativePath: "test/enabled/backup",
                                                 searchPathDirectory: .library,
                                                 isExcludedFromBackup: true)

            let resourceValuesEnabled = try URL(fileURLWithPath: storageEnabled.path, isDirectory: false)
                .resourceValues(forKeys: [.isExcludedFromBackupKey])
            XCTAssertTrue(resourceValuesEnabled.isExcludedFromBackup == true, "Resource value 'Exclude from Backup' was not set to true")
            try storageEnabled.delete()

        } catch let error {
            XCTFail(error.localizedDescription)
        }

    }

    func testDeleteStorageFile() {
        do {
            let fileManager = FileManager.default
            let fileStorage = try FileStorage(fileManager: fileManager,
                                              relativePath: "test/delete/",
                                              searchPathDirectory: .library,
                                              isExcludedFromBackup: false)

            XCTAssertTrue(fileManager.fileExists(atPath: fileStorage.path), "Initial storage file at \(fileStorage.path) does not exist")
            try fileStorage.delete()
            XCTAssertFalse(fileManager.fileExists(atPath: fileStorage.path), "Storage file at \(fileStorage.path) was not deleted")

        } catch let error {
            XCTFail("Error trying to test deletion of storage file: \(error)")
        }
    }

    /// Tests permancy of storage. Simulates behaviour when permanent storages are reinitialized (e.g. Relaunch of an App).
    ///
    /// - Parameter provider: Returns newly created storage
    /// - Throws: Exception
    func testPermanentStorage(provider: () throws -> Storage) throws {

        var initialStorage: Storage? = try provider()
        let encoder = FoundationEncoder<User>(encoder: .init())
        let decoder = FoundationDecoder<User>(decoder: .init())
        let user: [User] = [User(name: "Karl"), User(name: "Bernd")]
        // Clear storage first
        try initialStorage?.clear()
        // Store initial content and check if there are stored properly
        try initialStorage?.append(all: user, using: encoder)
        (try initialStorage?.all(using: decoder) ?? []).forEach { XCTAssertTrue(user.contains($0)) }

        // Dealocate storage in case storage
        initialStorage = nil

        let secondStorage = try provider()
        (try secondStorage.all(using: decoder)).forEach { XCTAssertTrue(user.contains($0)) }
    }
}
