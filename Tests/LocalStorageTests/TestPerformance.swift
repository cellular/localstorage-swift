import UIKit
import XCTest
import LocalStorage

class TestPerformance: XCTestCase {

    static let performanceRange: CountableRange = (1..<200)
    let userDefaultsStoragePath = "test.storage.performance"
    let userDefaults = UserDefaults.standard

    let testUsers = performanceRange.map { User(name: "Testuser #\($0)") }
    let encoder = FoundationEncoder<User>(encoder: JSONEncoder())
    let decoder = FoundationDecoder<User>(decoder: JSONDecoder())

    override func setUp() {
        super.setUp()
        userDefaults.removeObject(forKey: userDefaultsStoragePath)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        userDefaults.removeObject(forKey: userDefaultsStoragePath)
    }

    // MARK: Performance tests

    // MARK: Read perfomance

    // UserDefaults
    func testReadPerformanceUserDefaultsStorage() {

        let storage = UserDefaultsStorage(userDefaults: userDefaults, path: userDefaultsStoragePath)
        try? storage.append(all: testUsers, using: encoder)

        measure {

            TestPerformance.performanceRange.forEach {
                let currentUser = "Testuser #\($0)"
                _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
            }
        }
    }

    func testReadPerformanceCachedUserDefaultsStorage() {
        let userStorage = UserDefaultsStorage(userDefaults: userDefaults, path: userDefaultsStoragePath)
        let storage = CachedStorage(storage: userStorage)
        try? storage.append(all: testUsers, using: encoder)

        measure {
            TestPerformance.performanceRange.forEach {
                let currentUser = "Testuser #\($0)"
                _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
            }
        }
    }

    // FileStorage

    func testReadPerformanceFileStorage() {
        do {
            let storage = try FileStorage(fileManager: .default,
                                          relativePath: "test/read/testFileStorage",
                                          searchPathDirectory: .documents,
                                          isExcludedFromBackup: false)
            try storage.clear()
            try storage.append(all: testUsers, using: encoder)
            measure {
                TestPerformance.performanceRange.forEach {
                    let currentUser = "Testuser #\($0)"
                    _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
                }
            }
        } catch FileStorage.FileStorageError.invalidPath {
            XCTFail("Invalid Path Error!")

        } catch let error {
            XCTFail("Error trying to create file storage: \(error)")
        }
    }

    func testReadPerformanceCachedFileStorage() {
        do {
            let fileStorage = try FileStorage(fileManager: .default,
                                              relativePath: "test/read/testCachedFileStorage",
                                              searchPathDirectory: .documents,
                                              isExcludedFromBackup: false)
            let storage = CachedStorage(storage: fileStorage)
            try? storage.append(all: testUsers, using: encoder)

            measure {

                TestPerformance.performanceRange.forEach {
                    let currentUser = "Testuser #\($0)"
                    _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
                }
            }

        } catch FileStorage.FileStorageError.invalidPath {
            XCTFail("Invalid Path Error!")

        } catch let error {
            XCTFail("Error trying to create file storage: \(error)")
        }
    }

    // Memory
    func testReadPerformanceMemoryStorage() {

        let storage = MemoryStorage()

        try? storage.append(all: testUsers, using: encoder)

        measure {

            TestPerformance.performanceRange.forEach {
                let currentUser = "Testuser #\($0)"
                _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
            }
        }
    }

    func testReadPerformanceCachedMemoryStorage() {

        let storage = CachedStorage(storage: MemoryStorage())

        try? storage.append(all: testUsers, using: encoder)

        measure {

            TestPerformance.performanceRange.forEach {
                let currentUser = "Testuser #\($0)"
                _ = try? storage.first(using: decoder, where: { $0.name == currentUser } )
            }
        }
    }


    // MARK: Write perfomance

    // Userdefaults
    func testWritePerformanceUserDefaultsStorage() {

        let storage = UserDefaultsStorage(userDefaults: userDefaults, path:  userDefaultsStoragePath)

        measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
            try? storage.clear()
            self.startMeasuring()
            self.testUsers.forEach { try? storage.append($0, using: encoder) }
            self.stopMeasuring()
        }
    }

    func testWritePerformanceCachedUserDefaultsStorage() {
        let userStorage = UserDefaultsStorage(userDefaults: userDefaults, path: userDefaultsStoragePath)
        let storage = CachedStorage(storage: userStorage)

        measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
            try? storage.clear()
            self.startMeasuring()
            self.testUsers.forEach { try? storage.append($0, using: encoder) }
            self.stopMeasuring()
        }
    }

    // Memory

    func testWritePerformanceMemoryStorage() {

        let storage = MemoryStorage()

        measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
            try? storage.clear()
            self.startMeasuring()
            self.testUsers.forEach { try? storage.append($0, using: encoder) }
            self.stopMeasuring()
        }
    }

    func testWritePerformanceCachedMemoryStorage() {

        let storage = CachedStorage(storage: MemoryStorage())

        measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
            try? storage.clear()
            self.startMeasuring()
            self.testUsers.forEach { try? storage.append($0, using: encoder) }
            self.stopMeasuring()
        }
    }

    // FILE

    func testWritePerformanceFileStorage() {
        do {
            let storage = try FileStorage(fileManager: .default,
                                          relativePath: "test/write/testFileStorage",
                                          searchPathDirectory: .documents,
                                          isExcludedFromBackup: false)

            measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
                try? storage.clear()
                self.startMeasuring()
                self.testUsers.forEach { try? storage.append($0, using: encoder) }
                self.stopMeasuring()
            }
        } catch let error {
             XCTFail("Error testing FileStorage write performace: \(error)")
        }
    }

    func testWritePerformanceCachedFileStorage() {
        do {
            let storage = CachedStorage(storage: try FileStorage(fileManager: .default,
                                        relativePath: "test/write/testCachedFileStorage",
                                        searchPathDirectory: .documents,
                                        isExcludedFromBackup: false))

            measureMetrics(TestStorage.defaultPerformanceMetrics, automaticallyStartMeasuring: false) { [unowned self] in
                try? storage.clear()
                self.startMeasuring()
                self.testUsers.forEach { try? storage.append($0, using: encoder) }
                self.stopMeasuring()
            }
        } catch let error {
            XCTFail("Error testing FileStorage write performace: \(error)")
        }
    }
}
