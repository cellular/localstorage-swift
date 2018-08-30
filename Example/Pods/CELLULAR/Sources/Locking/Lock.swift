import Foundation

/// Read write lock
public protocol Lock {

    /// Locks reading and returns whatever the closure returns
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    func read<T>(_ closure: () throws -> T) rethrows -> T

    /// Locks writing and returns whatever the closure returns
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    @discardableResult
    func write<T>(_ closure: () throws -> T) rethrows -> T
}
