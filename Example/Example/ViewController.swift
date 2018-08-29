//
//  ViewController.swift
//  Example
//
//  Created by Michael Hass on 01.08.17.
//  Copyright © 2017 CELLULAR GmbH. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var createButton: UIButton?
    @IBOutlet private weak var stateLabel: UILabel?
    @IBOutlet private weak var userLabel: UILabel?

    // MARK: Properties

    private let userStorage = Storage.userStorage

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        userStorage.all { [weak self] user in
            self?.stateLabel?.text = "Initial load completed."
            self?.setLabel(for: user)
        }
    }

    // MARK: IBActions

    @IBAction private func tappedCreate(_ sender: UIButton) {
        // It is assured that second task will only start if first task is completed through the use of Locking
        // and DispatchQueues within LocalStorage.Manager.
        sender.isEnabled = false
        userStorage.replaceAll(with: createRandomUser()) { [weak self] in
            self?.stateLabel?.text = ""
            self?.userLabel?.text = ""
        }

        userStorage.all { [weak self] user in
            self?.stateLabel?.text = "Loaded newly created user"
            self?.setLabel(for: user)
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

