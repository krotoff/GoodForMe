//
//  SecureUnarchiveFromDataTransformer.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 17/06/2023.
//

import Foundation

final class SecureUnarchiveFromDataTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] { [NSArray.self] }
}
