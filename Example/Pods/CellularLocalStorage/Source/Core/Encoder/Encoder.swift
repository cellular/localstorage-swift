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

/// Encodes a specific model into raw JSON Data
public protocol Encoder {

    associatedtype Encodable

    /// Encodes model into raw JSON Data
    ///
    /// - Parameter object: Model to encode
    /// - Returns: JSON Data
    /// - Throws: Any error concrete encoder throws
    func encode(object: Encodable) throws -> Data
}
