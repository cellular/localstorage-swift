//
//  User.swift
//  Example
//
//  Created by Michael Hass on 02.08.17.
//  Copyright © 2017 CELLULAR GmbH. All rights reserved.
//

import Foundation

struct User: Codable {

    let name: String

    init(name: String) {
        self.name = name
    }
}
