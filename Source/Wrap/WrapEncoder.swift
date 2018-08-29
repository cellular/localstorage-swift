import Foundation
import Wrap

/// Encodes a specific model into raw JSON Data
/// by using Wrap as encoder
public struct WrapEncoder<T>: Encoder {

    public init() {}

    /// Encodes model into raw JSON Data
    ///
    /// - Parameter object: Model to encode
    /// - Returns: JSON Data
    /// - Throws: Any error concrete encoder throws
    public func encode(object: T) throws -> Data {
        return try wrap(object)
    }
}
