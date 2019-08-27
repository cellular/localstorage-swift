import Foundation
import XCTest
import LocalStorage


class TestDecodingEncoding: XCTestCase {

    /// Tests encoding and decoding
    func testDecodingAndEncoding() {

        do {
            let firstUser = User(name: "Karl")

            // Encode user to Data
            let encodedData = try NativeEncoder<User>().encode(object: firstUser)

            // Decode user from Data
            let decodedModel = try NativeDecoder<User>().decode(data: encodedData)

            XCTAssert(decodedModel.name == firstUser.name, "Encoded and decoded model does not match initial model.")

        } catch let error {
            
            XCTFail("Encoding or decoding error: \(error)")
        }
    }
}
