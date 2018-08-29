import Foundation

/// Encodes native object into JSON
public final class NativeEncoder<T: Encodable>: Encoder {

    private let encoder: JSONEncoder

    public init(encoder: JSONEncoder) {
        self.encoder = encoder
    }

    public func encode(object: T) throws -> Data {
        return try encoder.encode(object)
    }
}
