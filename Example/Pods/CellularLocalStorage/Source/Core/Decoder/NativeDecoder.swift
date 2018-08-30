import Foundation

/// Decodes JSON into native object using Swift.JSONDecoder
public final class NativeDecoder<T: Decodable>: Decoder {

    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    /// Decodes data into model
    ///
    /// - Parameter data: JSON Data to decode
    /// - Returns: Decoded model
    /// - Throws: Any error the concrete decoder throws
    public func decode(data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}
