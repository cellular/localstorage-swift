/************************************************************************
 CELLULAR Proprietary
 Copyright (c) 2015, CELLULAR GmbH. All Rights Reserved

 CELLULAR GmbH., Große Elbstraße 39, D-22767 Hamburg, GERMANY

 All data and information contained in or disclosed by this document are
 confidential and proprietary information of CELLULAR, and all rights
 therein are expressly reserved. By accepting this material, the
 recipient agrees that this material and the information contained
 therein are held in confidence and in trust. The material may only be
 used and/or disclosed as authorized in a license agreement controlling
 such use and disclosure.
 *************************************************************************/

import Foundation

public final class CachedStorage: Storage {

    /// Path to store data
    public var path: String { return storage.path }

    /// Returns list of stored raw data
    public var rawData: [Data] {
        return storage.rawData
    }

    /// Concrete storage to wrap a cache around
    private let storage: Storage

    /// Cahced decoded storage data
    private var cache: [Any]?

    /// Initializes a CachedStorage with a concrete storage that will
    /// be extended with caching.
    ///
    /// - Parameter storage: Storage to use caching on
    public init(storage: Storage) {

        self.storage = storage
    }

    // MARK: Save

    /// Saves a single object to storage.
    ///
    /// - Parameters:
    ///   - object: Object to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E: Encoder>(_ object: T, using encoder: E) throws where T == E.Encodable {

        cache?.append(object)
        try storage.append(object, using: encoder)
    }

    /// Appends a list of objects to storage.
    ///
    /// - Parameters:
    ///   - object: Objects to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E: Encoder>(all objects: [T], using encoder: E) throws where T == E.Encodable {

        // For some reason append list to array needs cast to [Any]
        cache?.append(contentsOf: objects as [Any])
        try storage.append(all: objects, using: encoder)
    }

    // MARK: Load

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func all<T, D: Decoder>(using decoder: D) throws -> [T] where T == D.Decodable {

        if let cache = cache { return cache.flatMap { $0 as? T } }

        let storedObjedts = try storage.all(using: decoder)
        cache = storedObjedts
        return storedObjedts
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

        // Remove element from cache
        if let indexToRemove = try all(using: decoder).index(where: predicate) {
            cache?.remove(at: indexToRemove)
        }

        // Remove element from actual storage
        return try storage.remove(using: decoder, encoder: encoder, where: predicate)
    }

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    public func replaceAll<T, E: Encoder>(with objects: [T], using encoder: E) throws where T == E.Encodable {
        cache = objects
        try storage.replaceAll(with: objects, using: encoder)
    }

    /// Removes all objects from storage and cache
    public func clear() throws {

        cache = nil
        try storage.clear()
    }
}
