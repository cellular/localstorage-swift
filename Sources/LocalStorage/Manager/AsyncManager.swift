import Foundation
import CELLULAR

/// Extentends LocalStorage.Manager with asynchronous storage handling.
public final class AsyncManager {

    // MARK: properties

    /// Sync manager to access storage through
    /// Handles every storage operation.
    weak var manager: Manager?

    /// Returns newly created default queue to dispatch tasks to
    public static var defaultAsyncQueue: DispatchQueue {
        return DispatchQueue(label: "queue.async.storage.concurrent", qos: .background, attributes: .concurrent)
    }

    /// Queue to dispatch asynchronously any operation on a storage
    private let queue: DispatchQueue

    /// Creates async manager with a queue to dispatch on
    ///
    /// - Parameter manager: Manager to pass operations on storages to
    init(queue: DispatchQueue) {
        self.queue = queue
    }

    // MARK: Save

    /// Saves a object to a storage specified by it's identifier
    ///
    /// - Parameters:
    ///   - object: Object to save
    ///   - storageIdentifier: String identifying storage
    ///   - encoder: Encoder to use to save the object
    /// - Throws: Any exception the storage throws
    public func append<T, E: Encoder>(_ object: T,
                                      to storageIdentifier: String,
                                      using encoder: E,
                                      completion: @escaping (Result<T, Error>) -> Void) where T == E.Encodable {

        handle(task: { $0.append(object, to: storageIdentifier, using: encoder) }, completion: completion)
    }

    /// Appends a list of objects to a sepcific storage
    ///
    /// - Parameters:
    ///   - objects: Objects to save
    ///   - storageIdentifier: String identifying storage
    ///   - encoder: Encoder to use to save the object
    /// - Throws: Any exception the storage throws
    public func append<T, E: Encoder>(all objects: [T],
                                      to storageIdentifier: String,
                                      using encoder: E,
                                      completion: @escaping (Result<[T], Error>) -> Void) where T == E.Encodable {

        handle(task: { $0.append(all: objects, to: storageIdentifier, using: encoder)}, completion: completion)
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
                                     using decoder: D,
                                     completion: @escaping (Result<T?, Error>) -> Void) where T == D.Decodable {

        handle(task: { $0.first(from: storageIdentifier, using: decoder) }, completion: completion)
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
                                     where predicate: @escaping (T) -> Bool,
                                     completion: @escaping (Result<T?, Error>) -> Void) where T == D.Decodable {

        handle(task: { $0.first(from: storageIdentifier, using: decoder, where: predicate) }, completion: completion)
    }

    /// Loads list of model instances that were decodable with the given decoder and matching the predicate
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func filter<T, D: Decoder>(from storageIdentifier: String,
                                      using decoder: D,
                                      including predicate: @escaping (T) -> Bool,
                                      completion: @escaping (Result<[T], Error>) -> Void ) where T == D.Decodable {

        handle(task: { $0.filter(from: storageIdentifier, using: decoder, including: predicate) }, completion: completion)
    }

    /// Cecks if first object storage matching predicate exists.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The first match or `nil` if there was no match.
    public func contains<T, D: Decoder>(_ storageIdentifier: String,
                                        using decoder: D,
                                        where predicate: @escaping (T) -> Bool,
                                        completion: @escaping (Result<Bool, Error>) -> Void) where T == D.Decodable {

        handle(task: { $0.contains(storageIdentifier, using: decoder, where: predicate) }, completion: completion)
    }

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func all<T, D: Decoder>(from storageIdentifier: String,
                                   using decoder: D,
                                   completion: @escaping (Result<[T], Error>) -> Void) where T == D.Decodable {

        handle(task: { $0.all(from: storageIdentifier, using: decoder) }, completion: completion)
    }

    /// loads last model instance in storage that was decodable with the given decoder.
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Returns list of decoded models
    public func last<T, D: Decoder>(from storageIdentifier: String,
                                    using decoder: D,
                                    completion: @escaping (Result<T?, Error>) -> Void) where T == D.Decodable {

        handle(task: { $0.last(from: storageIdentifier, using: decoder) }, completion: completion)
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
    public func remove<T, D: Decoder, E: Encoder>(from storageIdentifier: String,
                                                  using decoder: D,
                                                  encoder: E,
                                                  where predicate: @escaping (T) -> Bool,
                                                  completion: @escaping (Result<T?, Error>) -> Void)
                                                  where T == D.Decodable, T == E.Encodable {

        handle(task: { $0.remove(from: storageIdentifier, using: decoder, encoder: encoder, where: predicate) }, completion: completion)
    }

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - storageIdentifier: String identifying storage
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    public func replaceAll<T, E: Encoder>(in storageIdentifier: String,
                                          with objects: [T],
                                          using encoder: E,
                                          completion: @escaping (Result<[T], Error>) -> Void) where T == E.Encodable {

        handle(task: { $0.replaceAll(in: storageIdentifier, with: objects, using: encoder) }, completion: completion)
    }

    /// Removes all objects from storage
    ///
    ///   - storageIdentifier: String identifying storage
    /// - Throws: Any error managed storage throws
    public func clear(storage storageIdentifier: String, completion: @escaping (Result<Bool, Error>) -> Void) {

        handle(task: { $0.clear(storage: storageIdentifier) }, completion: completion)
    }

    // MARK: - Convenience

    /// Ensures that given task is asynchronously dispatched on self's queue and completed on main queue.
    ///
    /// - Parameters:
    ///   - task: Task to perform on self's queue.
    ///   - completion: Closure to perform if task is done.
    private func handle<T>(task: @escaping (Manager) -> Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {

        queue.async { [weak self] in
            guard let manager = self?.manager else {
                let message = "Could not perform async operation on storage. AsyncManager dealocated."
                DispatchQueue.main.async { completion(.failure(.notFound(message))) }
                return
            }

            let result = task(manager)
            DispatchQueue.main.async { completion(result) }
        }
    }
}
