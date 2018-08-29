import Foundation

/// Class that ensures thead safe handling of an object
public final class Protected<T> {

    /// Lock to be used to ensure thread safety
    private var lock: Lock

    /// Value to access safely
    private var value: T

    /// Initializes an object with a value and a lock
    ///
    /// - Parameters:
    ///   - value: Value to access safely
    ///   - lock: Lock to be used to ensure thread safety
    public init(initialValue value: T, lock: Lock) {
        self.value = value
        self.lock = lock
    }

    /// Safely reads stored value
    ///
    /// - Parameter closure: Forwarding value to caller
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    public func read<R>(_ closure: (T) throws -> R) rethrows -> R {
        return try lock.read {
            try closure(value)
        }
    }

    /// Safely allows write access to stored value
    ///
    /// - Parameter closure: Forwarding value to caller
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    @discardableResult
    public func write<R>(_ closure: (inout T) throws -> R) rethrows -> R {
        return try lock.write {
            try closure(&value)
        }
    }
}
