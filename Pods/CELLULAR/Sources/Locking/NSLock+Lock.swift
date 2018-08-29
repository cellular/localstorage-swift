import Foundation

extension NSLock: Lock {

    /// Locks reading and returns whatever the closure returns
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    public func read<T>(_ closure: () throws -> T) rethrows -> T {
        defer { unlock() }
        lock()
        return try closure()
    }

    /// Locks writing and returns whatever the closure returns
    ///
    /// - Parameter closure: Closure to lock
    /// - Returns: Whatever the closure returns
    /// - Throws: Whatever the closure throws
    @discardableResult
    public func write<T>(_ closure: () throws -> T) rethrows -> T {
        return try read(closure)
    }
}
