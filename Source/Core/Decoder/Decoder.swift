import Foundation

/// Decodes raw JSON data into a sepcific model
public protocol Decoder {

    associatedtype Decodable

    /// Decodes data into model
    ///
    /// - Parameter data: JSON Data to decode
    /// - Returns: Decoded model
    /// - Throws: Any error the concrete decoder throws
    func decode(data: Data) throws -> Decodable
}
