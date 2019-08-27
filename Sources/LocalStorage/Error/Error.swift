import Foundation

/// Storage Error
///
/// - notFound: Resource not found
/// - encoding: Encoding error
/// - decoding: Decoding Error
public enum Error: Swift.Error {

    case notFound(String)
    case encoding(String)
    case decoding(String)
}
