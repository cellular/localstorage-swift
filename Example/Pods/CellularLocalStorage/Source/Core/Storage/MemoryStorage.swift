import Foundation

/// Storage that persists models in memory as raw data objects.
public final class MemoryStorage: Storage {

    /// Path to store data
    public let path: String

    /// Initializes a MemoryStorage.
    ///
    public init() {
        rawData = []
        path = "memory.storage.path"
    }

    /// Returns or sets raw data stored in UserDefaults
    private(set) public var rawData: [Data]

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
        rawData.append(try encoder.encode(object: object))
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
        rawData.append(contentsOf: encodedObjects)
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
        rawData.removeAll()
    }
}
