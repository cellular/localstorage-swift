import Foundation

struct User: Codable {
    let name: String

    init(name: String) {
        self.name = name
    }
}

extension User: Equatable {

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}
