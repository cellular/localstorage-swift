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

/// Generic enumeration to wrap two models that are actually different (e.g. model that has been parsed and
/// error that may occured within serialization), but should be treated equally within the returning value,
/// within a single enumeration that allows none-nil returns with additional information instead.
///
/// - success: Wraps the successful result model.
/// - failure: Wraps the failure result model
public enum Result<Success, Failure> {
    case success(Success)
    case failure(Failure)

    /// Whether the result was successful `.success`, or failed `.failure`
    public var isSuccessful: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

/// Allows results to be treated as string convertibles for fast access to printable descriptions.
extension Result: CustomStringConvertible, CustomDebugStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case let .success(model):
            return "Success result - model:\n\(model)"
        case let .failure(message):
            return "Failure result - error:\n\(message)"
        }
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case let .success(model):
            return "Success result - model:\n\(model)"
        case let .failure(message):
            return "Failure result - error:\n\(message)"
        }
    }
}

/// Allows results to be treated as equatables if the associated types are equatable.
extension Result where Success: Equatable, Failure: Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Result, rhs: Result) -> Bool {
        if case let .success(lhs) = lhs {
            switch rhs {
            case let .success(rhs): return lhs == rhs
            default: break
            }
        } else if case let .failure(lhs) = lhs {
            switch rhs {
            case let .failure(rhs): return lhs == rhs
            default: break
            }
        }
        return false
    }
}
