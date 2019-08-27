import Foundation

struct User: Codable {
    let name: String
}

extension User: Equatable {

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}
