import Foundation
import LocalStorage
import CELLULAR

// MARK: - Internal Storage handling

final class Storage {

    // Identifies existing Storages. Used internally for easy storage access through LocalStorage.Manager.
   private enum Identifier: String {
        case user

        // Path to store data to.
        var path: String {
            switch self {
            case .user: return "example.storage.user"
            }
        }
    }

    // Shared Instance managing all storages needed within the App. Should not be access directly by the client.
    // NOTE: To clear up responsibilities and make code more testable, create a wrapper class that hides storage access from client
    // and prepares requested data for the client.
    private static let manager: LocalStorage.Manager = {

        // Storage persisting data to user storage to  key 'path'
        let defaultsStorage = UserDefaultsStorage(userDefaults: UserDefaults.standard, path: Identifier.user.path)
        // Wrap defaultsStorage with CachedStorage for faster access.
        let userStorage = CachedStorage(storage: defaultsStorage)
        // Dictionary containing all storages handled by Manager instance
        let storages = [Identifier.user.rawValue: userStorage]
        // DispatchLock to allow multiple reads but single write operations on storages. It will perform all
        // operations on a concurrent DispatchQueue. It is also possible to simply use a NSLock, which may be
        // easier to handle due to reduced thread states. On the downside NSLock has a lower performance on read
        // operations than a DispatchLock.
        let lock = DispatchLock(queue: DispatchQueue(label: "example.queue.storage", attributes: .concurrent))
        // Serial queue for async handling. Enables sequential dispatching of completion blocks.
        // Needed for required behaviour in example app.
        // NOTE: Default Manager(storages: _, lock: _) uses a concurrent queue.
        let asyncQueue = DispatchQueue(label: "async.queue")

        return Manager(storages: storages, lock: lock, asyncQueue: asyncQueue)
    }()
}

// MARK: - Public Interface

extension Storage {

    static let userStorage = UserStorage(manager: manager)

    // Specific class offering an public interface for handling storage operations on user objects.
    // NOTE: To clear up responsibilities and make code more testable, create a wrapper class that hides storage access from the client
    // and prepares requested data for the client. Additionally try to  prefer async over sync operations if possible.
    final class UserStorage {

        // Used internally to handle storage operations on.
        private let manager: LocalStorage.Manager

        init(manager: LocalStorage.Manager) {
            self.manager = manager
        }

        /// Asynchronously loads user from storage
        ///
        /// - Parameter completion: Completion
        func all(completion: @escaping ([User]) -> Void) {
            let decoder = FoundationDecoder<User>(decoder: JSONDecoder())
            manager.async.all(from: Identifier.user.rawValue, using: decoder) { result in
                switch result {
                case .success(let user):
                    completion(user)
                case .failure(let error):
                    print(error)
                    completion([])
                }
            }
        }

        // Replaces stored user list with given list of user
        func replaceAll(with user: [User], completion: @escaping () -> Void) {
            let encoder = FoundationEncoder<User>(encoder: JSONEncoder())
            manager.async.replaceAll(in: Identifier.user.rawValue, with: user, using: encoder) { result in
                switch result {
                case .success(_):
                    completion()
                case .failure(let error):
                    print(error)
                    completion()
                }
            }
        }
    }
}
