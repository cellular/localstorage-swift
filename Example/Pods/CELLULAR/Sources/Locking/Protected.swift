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

/// Class that ensures thead safe handling
/// of an object
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
