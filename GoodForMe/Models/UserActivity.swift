//
//  UserActivity.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 25/06/2023.
//

import Foundation.NSUUID
import CoreData.NSManagedObjectID

public struct UserActivity: Equatable {

    // MARK: - Public types
    // MARK: - Internal types
    // MARK: - Private types

    // MARK: - Public properties

    public var managedObjectID: NSManagedObjectID?
    public static let initial = UserActivity()

    // MARK: - Internal properties

    var id: String = UUID().uuidString
    var name: String = .init()
    var dates: [Date] = []

    // MARK: - Init

    public init(managedObject: UserActivityMO) {
        self.managedObjectID = managedObject.objectID

        if let id = managedObject.id {
            self.id = id.uuidString
        }

        if let name = managedObject.name {
            self.name = name
        }

        if let dates = managedObject.dates {
            self.dates = dates
        }
    }

    private init() {}
}

extension UserActivity: CoreDataManagable {
    public func updatedManagedObject(_ current: UserActivityMO) -> UserActivityMO {
        current.id = UUID(uuidString: id)
        current.name = name
        current.dates = dates

        return current
    }
}
