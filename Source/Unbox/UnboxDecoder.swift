import Foundation
import Unbox

/// Decodes raw JSON data into a sepcific model by using Unbox
public struct UnboxDecoder<T: Unboxable>: Decoder {

    public init() {}

    /// Decodes data into model
    ///
    /// - Parameter data: JSON Data to decode
    /// - Returns: Decoded model
    /// - Throws: unbox error
    public func decode(data: Data) throws -> T {
        return try unbox(data: data)
    }
}
