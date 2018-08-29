import Foundation

/// Readers writer lock => Allows multiple simultanous reading operations but only single writing operation
public final class DispatchLock: Lock {

    /// Queue to use for locking mechanism
    private let dispatchQueue: DispatchQueue

    /// Creates labeled DispatchLock.
    ///
    /// - Parameters:
    ///   - queue: Queue to dispatch reading or writing operations on.
    public init(queue: DispatchQueue) {
        self.dispatchQueue = queue
    }

    /// Synchrounously dispatches reading operation to queue
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    public func read<T>(_ closure: () throws -> T) rethrows -> T {
        return try dispatchQueue.sync {
            return try closure()
        }
    }

    /// Synchrounously dispatches writing operation to queue
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    @discardableResult
    public func write<T>(_ closure: () throws -> T) rethrows -> T {
        return try dispatchQueue.sync(flags: .barrier) {
            return try closure()
        }
    }
}
