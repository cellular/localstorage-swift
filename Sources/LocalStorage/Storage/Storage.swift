import Foundation

/// Defines a standardized behaviour for persisting data within module LocalStorage.
public protocol Storage {

    // MARK: Properties

    /// Path to store data
    var path: String { get }

    /// Returns list of stored raw data
    var rawData: [Data] { get }

    /// OPTIONAL
    /// Returns count of objects currently stored in storage
    var count: Int { get }

    // MARK: Save

    /// Saves a single object to storage.
    ///
    /// - Parameters:
    ///   - object: Object to be saved
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encdoding error
    func append<T, E: Encoder>(_ object: T, using encoder: E) throws where T == E.Encodable

    /// Saves a list of objects to storage.
    ///
    /// - Parameters:
    ///   - object: Objects to be saved
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encdoding error
    func append<T, E: Encoder>(all objects: [T], using encoder: E) throws where T == E.Encodable

    // MARK: Load

    /// OPTIONAL
    /// Returns first decoded object from storage or nil
    ///
    /// - Parameter decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: First object or nil
    /// - Throws: Decoding error
    func first<T, D: Decoder>(using decoder: D) throws -> T? where T == D.Decodable

    /// OPTIONAL
    /// Loads first object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    /// - Throws: Decoding error
    func first<T, D: Decoder>(using decoder: D, where predicate: (T) -> Bool) throws -> T? where T == D.Decodable

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    func all<T, D: Decoder>(using decoder: D) throws -> [T] where T == D.Decodable

    /// OPTIONAL
    /// Loads list of model instances that were decodable with the given decoder and matching the predicate
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    func filter<T, D: Decoder>(using decoder: D, including predicate: (T) -> Bool) throws -> [T] where T == D.Decodable

    /// OPTIONAL
    /// Loads first object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    /// - Throws: Decoding error
    func contains<T, D: Decoder>(using decoder: D, where predicate: (T) -> Bool) throws -> Bool where T == D.Decodable

    /// OPTIONAL
    /// Returns last object from storage or nil if storage is empty
    ///
    /// - Parameter decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: First object or nil
    /// - Throws: Decoding error
    func last<T, D: Decoder>(using decoder: D) throws -> T? where T == D.Decodable

    // MARK: Delete

    /// Removes first object from storage matching predicate
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
    func remove<T, D: Decoder, E: Encoder>(using decoder: D, encoder: E, where predicate: (T) -> Bool) throws -> T?
        where T == D.Decodable, T == E.Encodable

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    func replaceAll<T, E: Encoder>(with objects: [T], using encoder: E) throws where T == E.Encodable

    /// Removes all objects from storage
    func clear() throws

}

// MARK: - Default Implementation / Convenience

extension Storage {

    /// Returns count of objects currently stored in storage
    public var count: Int { return rawData.count }

    /// Returns first decoded object from storage or nil
    ///
    /// - Parameter decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: First object or nil
    public func first<T, D: Decoder>(using decoder: D) throws -> T? where T == D.Decodable {
        return try all(using: decoder).first
    }

    /// Loads first object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    /// - Throws: Decoding error
    public func first<T, D: Decoder>(using decoder: D, where predicate: (T) -> Bool) throws -> T? where T == D.Decodable {
        return try all(using: decoder).first(where: predicate)
    }

    /// Loads list of model instances that were decodable with the given decoder and matching the predicate
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func filter<T, D: Decoder>(using decoder: D, including predicate: (T) -> Bool) throws -> [T] where T == D.Decodable {
        return try all(using: decoder).filter(predicate)
    }

    /// Loads first object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    /// - Throws: Decoding error
    public func contains<T, D: Decoder>(using decoder: D, where predicate: (T) -> Bool) throws -> Bool where T == D.Decodable {
        return try all(using: decoder).contains(where: predicate)
    }

    /// Returns last object from storage or nil if storage is empty
    ///
    /// - Parameter decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: First object or nil
    /// - Throws: Decoding error
    public func last<T, D: Decoder>(using decoder: D) throws -> T? where T == D.Decodable {
        return try all(using: decoder).last
    }
}
