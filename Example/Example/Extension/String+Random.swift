//
//  String+Random.swift
//  Example
//
//  Created by Michael Hass on 02.08.17.
//  Copyright © 2017 CELLULAR GmbH. All rights reserved.
//

import Foundation
extension String {
    static func random(length: Int = 5) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

         (0..<length).forEach { _ in
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

