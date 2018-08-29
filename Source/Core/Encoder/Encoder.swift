import Foundation

/// Encodes a specific model into raw JSON Data
public protocol Encoder {

    associatedtype Encodable

    /// Encodes model into raw JSON Data
    ///
    /// - Parameter object: Model to encode
    /// - Returns: JSON Data
    /// - Throws: Any error concrete encoder throws
    func encode(object: Encodable) throws -> Data
}
