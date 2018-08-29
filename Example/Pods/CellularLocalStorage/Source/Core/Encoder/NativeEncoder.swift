/************************************************************************
 CELLULAR Proprietary
 Copyright (c) 2015, CELLULAR GmbH. All Rights Reserved

 CELLULAR GmbH., Große Elbstraße 39, D-22767 Hamburg, GERMANY

 All data and information contained in or disclosed by this document are
 confidential and proprietary information of CELLULAR, and all rights
 therein are expressly reserved. By accepting this material, the
 recipient agrees that this material and the information contained
 therein are held in confidence and in trust. The material may only be
 used and/or disclosed as authorized in a license agreement controlling
 such use and disclosure.
 *************************************************************************/


import Foundation

/// Encodes native object into JSON
public final class NativeEncoder<T: Encodable>: Encoder {

    private let encoder: JSONEncoder

    public init(encoder: JSONEncoder) {
        self.encoder = encoder
    }

    public func encode(object: T) throws -> Data {
        return try encoder.encode(object)
    }
}
