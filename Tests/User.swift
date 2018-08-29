import Foundation
import Unbox

struct User: Unboxable, Codable {
    let name: String

    init(name: String) {
        self.name = name
    }
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
    }
}

extension User: Equatable {

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}
