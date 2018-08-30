import Foundation

struct User: Codable {

    let name: String

    init(name: String) {
        self.name = name
    }
}
