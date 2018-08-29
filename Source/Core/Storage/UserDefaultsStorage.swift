import Foundation

/// Storage that persists data into userDefaults
public final class UserDefaultsStorage: Storage {

    /// User defaults to store data in.
    private let userDefaults: UserDefaults

    /// Path to store data
    public let path: String

    /// Initializes a UserDefaultsStorage with a path referencing stored
    /// data within UserDefaults.
    ///
    /// - Parameter path: Path in UserDefaults to store data. In this context
    // the path acts like a uniqueue key accessing a dictionary (UserDefaults).
    ///
    public init(userDefaults: UserDefaults, path: String) {
        self.path = path
        self.userDefaults = userDefaults
    }

    /// Returns or sets raw data stored in UserDefaults
    private(set) public var rawData: [Data] {
        get {
            guard let data = userDefaults.object(forKey: path) as? Data,
                  let storedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Data] else { return [] }
            return storedData
        } set {
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: newValue), forKey: path)
        }
    }

    /// Returns the count of items stored in storage
    public var count: Int {
        return rawData.count
    }

    // MARK: Save

    /// Saves a single object to storage.
    ///
    /// - Parameters:
    ///   - object: Object to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E: Encoder>(_ object: T, using encoder: E) throws where T == E.Encodable {

        var storedData = rawData
        storedData.append(try encoder.encode(object: object))
        rawData = storedData
    }

    /// Appends a list of objects to storage.
    ///
    /// - Parameters:
    ///   - object: Objects to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E: Encoder>(all objects: [T], using encoder: E) throws where T == E.Encodable {

        // encode list of object instance to a data
        let encodedObjects = try objects.map { try encoder.encode(object: $0) }

        // append encoded objects to stored data list
        var storedData = rawData
        storedData.append(contentsOf: encodedObjects)
        rawData = storedData
    }

    // MARK: Load

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func all<T, D: Decoder>(using decoder: D) throws -> [T] where T == D.Decodable {

        return try rawData.compactMap { try decoder.decode(data: $0) }
    }

    // MARK: Delete

    /// Removes a object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - encoder : Encoder to use to encode model to data
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: Removed object or nil if nothing was removed
    /// - Throws: Decoding or encoding error
    @discardableResult
    public func remove<T, D: Decoder, E: Encoder>(using decoder: D, encoder: E, where predicate: (T) -> Bool) throws -> T?
        where T == D.Decodable, T == E.Encodable {

        // Make list of stored models mutable to return instance later
        var storedModels = try all(using: decoder)

        /// return nil if there is no instance matching predicate
        guard let indexToRemove = storedModels.index(where: predicate) else { return nil }

        // Remove object at given index from stored data list
        // and overwrite storage with new list
        var storedData = rawData
        storedData.remove(at: indexToRemove)
        rawData = storedData

        return storedModels.remove(at: indexToRemove)
    }

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    public func replaceAll<T, E: Encoder>(with objects: [T], using encoder: E) throws where T == E.Encodable {

        // encode list of object instance to a data
        rawData = try objects.map { try encoder.encode(object: $0) }
    }

    /// Removes all objects from storage
    public func clear() throws {

        userDefaults.removeObject(forKey: path)
    }
}
