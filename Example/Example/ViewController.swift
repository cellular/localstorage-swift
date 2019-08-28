import UIKit

final class ViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var createButton: UIButton?
    @IBOutlet private weak var stateLabel: UILabel?
    @IBOutlet private weak var userLabel: UILabel?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?

    // MARK: Properties

    private let userStorage = Storage.userStorage

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator?.startAnimating()

        userStorage.all { [weak self] user in
            self?.stateLabel?.text = "Initial load completed."
            self?.setLabel(for: user)
            self?.activityIndicator?.stopAnimating()
        }
    }

    // MARK: IBActions

    @IBAction private func tappedCreate(_ sender: UIButton) {
        // It is assured that second task will only start if first task is completed through the use of Locking
        // and DispatchQueues within LocalStorage.Manager.

        sender.isEnabled = false
        stateLabel?.text = "Creating new user"
        userLabel?.text = ""
        activityIndicator?.startAnimating()

        userStorage.replaceAll(with: createRandomUser()) {
            sleep(1)
        }

        userStorage.all { [weak self] user in
            self?.stateLabel?.text = "Loaded newly created user"
            self?.setLabel(for: user)
            self?.activityIndicator?.stopAnimating()
            sender.isEnabled = true
        }
    }

    // MARK: Convenience

    private func createRandomUser() -> [User] {
        return (0..<10).map { index in User(name: "#\(index) \(String.random())") }
    }

    private func setLabel(for user: [User]) {
        userLabel?.text =  user.map { $0.name }.joined(separator: "\n")
    }
}

// MARK: - Private extension

private extension String {
    static func random(length: Int = 5) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

         (0..<length).forEach { _ in
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

