import Foundation
import CELLULAR

/// Handles multiple instances of storages synchronously and safely.
public final class Manager {

    // MARK: Properties

    /// Returns manager for async handling of storages.
    /// Initializer ensures creation of async property.
    public let async: AsyncManager

    /// Wrapper model to ensure thread safe access to storages
    private let protected: Protected<[String: Storage]>

    // MARK: Init

    /// Creates Manager with a dictionary of storages
    ///
    /// - Parameter storages: Storages to manage
    public init(storages: [String: Storage], lock: Lock, asyncQueue: DispatchQueue = AsyncManager.defaultAsyncQueue) {

        protected = Protected(initialValue: storages, lock: lock)
        async = AsyncManager(queue: asyncQueue)
        async.manager = self
    }

    // MARK: Save

    /// Saves a object to a storage specified by it's identifier
    ///
    /// - Parameters:
    ///   - object: Object to save
    ///   - storageIdentifier: String identifying storage
    ///   - encoder: Encoder to use to save the object
    /// - Throws: Any exception the storage throws
    @discardableResult
    public func append<T, E: Encoder>(_ object: T,
                                      to storageIdentifier: String,
                                      using encoder: E) -> Result<T, Error> where T == E.Encodable {

        return write(to: storageIdentifier, task: {
            try $0.append(object, using: encoder)
            return .success(object)

        }, customError: {
            return .encoding("Error trying to save data to storage: \($0)")
        })
    }

    /// Appends a list of objects to a sepcific storage
    ///
    /// - Parameters:
    ///   - objects: Objects to save
    ///   - storageIdentifier: String identifying storage
    ///   - encoder: Encoder to use to save the object
    /// - Throws: Any exception the storage throws
    @discardableResult
    public func append<T, E: Encoder>(all objects: [T],
                                      to storageIdentifier: String,
                                      using encoder: E) -> Result<[T], Error> where T == E.Encodable {

        return write(to: storageIdentifier, task: {
            try $0.append(all: objects, using: encoder)
            return .success(objects)

        }, customError: {
            return .encoding("Error trying to save data to storage: \($0)")
        })
    }

    // MARK: load

    /// Loads first object from storage matching predicate.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    public func first<T, D: Decoder>(from storageIdentifier: String,
                                     using decoder: D) -> Result<T?, Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.first(using: decoder))

        }, customError: {
            return .decoding("Error trying to load first from storage: \($0)")
        })
    }

    /// Loads first object from storage matching predicate.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    public func first<T, D: Decoder>(from storageIdentifier: String,
                                     using decoder: D,
                                     where predicate: (T) -> Bool) -> Result<T?, Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.first(using: decoder, where: predicate))

        }, customError: {
            return .decoding("Error trying to load first from storage: \($0)")
        })
    }

    /// Loads list of model instances that were decodable with the given decoder and matching the predicate
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func filter<T, D: Decoder>(from storageIdentifier: String,
                                      using decoder: D,
                                      including predicate: (T) -> Bool) -> Result<[T], Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.filter(using: decoder, including: predicate))

        }, customError: {
            return .decoding("Error trying to filter data from storage: \($0)")
        })
    }

    /// Checks whether a item is contained in a storage.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: Ttrue if item is contained in storage.
    public func contains<T, D: Decoder>(_ storageIdentifier: String,
                                        using decoder: D,
                                        where predicate: (T) -> Bool) -> Result<Bool, Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.contains(using: decoder, where: predicate))

        }, customError: {
            return .decoding("Error trying to load data from storage: \($0)")
        })
    }

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Returns list of decoded models
    public func all<T, D: Decoder>(from storageIdentifier: String, using decoder: D) -> Result<[T], Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.all(using: decoder))

        }, customError: {
            return .decoding("Error trying to load data from storage: \($0)")
        })
    }

    /// loads last model instance in storage that was decodable with the given decoder.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Returns list of decoded models
    public func last<T, D: Decoder>(from storageIdentifier: String, using decoder: D) -> Result<T?, Error> where T == D.Decodable {

        return read(from: storageIdentifier, task: {
            return try .success($0.last(using: decoder))

        }, customError: {
            return .decoding("Error trying to load data from storage: \($0)")
        })
    }

    // MARK: Delete

    /// Removes a object from storage matching predicate
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - encoder : Encoder to use to encode model to data
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: Removed object or nil if nothing was removed
    /// - Throws: Decoding or encoding error
    @discardableResult
    public func remove<T, D: Decoder, E: Encoder>(from storageIdentifier: String, using decoder: D, encoder: E,
                                                  where predicate: (T) -> Bool) -> Result<T?, Error>
                                                  where T == D.Decodable, T == E.Encodable {

        return write(to: storageIdentifier, task: {
            return .success(try $0.remove(using: decoder, encoder: encoder, where: predicate))

        }, customError: {
            return .decoding("Error trying to load data from storage: \($0)")
        })
    }

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    @discardableResult
    public func replaceAll<T, E: Encoder>(in storageIdentifier: String, with objects: [T],
                                          using encoder: E) -> Result<[T], Error> where T == E.Encodable {

        return write(to: storageIdentifier, task: {
            try $0.replaceAll(with: objects, using: encoder)
            return .success(objects)

        }, customError: {
            return .encoding("Error trying to replace data from storage: \($0)")
        })
    }

    /// Removes all objects from storage
    ///
    ///   - storageIdentifier: String identifying storage
    /// - Throws: Any error managed storage throws
    @discardableResult
    public func clear(storage storageIdentifier: String) -> Result<Bool, Error> {

        return write(to: storageIdentifier, task: {
            try $0.clear()
            return .success(true)

        }, customError: {
            return .encoding("Error trying to clear storage: \($0)")
        })
    }

    // MARK: Convenience

    /// Writes to a named storage by performing a given task. In case of a an error while writing, the custom error will be returned
    /// as result. In case the named storage does not exist, '.notFound' will be returned as result.
    ///
    /// - Parameters:
    ///   - storageIdentifier: Identifier of the storage to perform a task on.
    ///   - task: Task to perform on storage.
    ///   - customError: Transforms any error thrown by a storage instance to a LocalStorage.Error.
    /// - Returns: Returns a Result with either a Object or an Error
    private func write<T>(to storageIdentifier: String,
                          task: (Storage) throws -> (Result<T, Error>),
                          customError: (Swift.Error) -> Error) -> Result<T, Error> {

        do {
            return try protected.write {
                guard let storage = $0[storageIdentifier] else {
                    return .failure(.notFound("storage -\(storageIdentifier)- does not exist "))
                }
                return try task(storage)
            }
        } catch let error {
            return .failure(.encoding("Error trying to save data to storage: \(error)"))
        }
    }

    /// Reads from a named storage by performing a given task. In case of a an error while writing, the custom error will be returned
    /// as result. In case the named storage does not exist, '.notFound' will be returned as result.
    ///
    /// - Parameters:
    ///   - storageIdentifier: Identifier of the storage to perform a task on.
    ///   - task: Task to perform on storage.
    ///   - customError: Transforms any error thrown by a storage instance to a LocalStorage.Error.
    /// - Returns: Returns a Result with either a Object or an Error
    private func read<T>(from storageIdentifier: String,
                         task: (Storage) throws -> (Result<T, Error>),
                         customError: (Swift.Error) -> Error) -> Result<T, Error> {

        do {
            return try protected.read {
                guard let storage = $0[storageIdentifier] else {
                    return .failure(.notFound("storage -\(storageIdentifier)- does not exist "))
                }
                return try task(storage)
            }
        } catch let error {
            return .failure(.encoding("Error trying to save data to storage: \(error)"))
        }
    }
}
