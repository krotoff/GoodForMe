//
//  CoreDataGateway.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import Foundation
import CoreData
import UIKit

public enum CollectionChangeKind {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case fullReload
}

public protocol CoreDataFetchManagable: NSManagedObject, NSFetchRequestResult {}

public protocol CoreDataManagable {
    associatedtype ManagedObjectType: NSManagedObject

    var managedObjectID: NSManagedObjectID? { get }

    init(managedObject: ManagedObjectType)

    func updatedManagedObject(_ current: ManagedObjectType) -> ManagedObjectType
}

public protocol CoreDataGatewayType {
    func createManagedObject<ObjectType: NSManagedObject>() -> ObjectType
    func fetchData<ObjectType: CoreDataManagable>() -> [ObjectType]
    func saveObject<ObjectType: CoreDataManagable>(_ object: ObjectType)
    func deleteObject<ObjectType: CoreDataManagable>(_ object: ObjectType)

    func createFetchResultsController<ObjectType: NSManagedObject>(
        sortDescriptors: [NSSortDescriptor]
    ) -> NSFetchedResultsController<ObjectType>

    func saveChangesIfNeeded()
}

public extension NSManagedObject {
    static var entityName: String { String(describing: Self.self) }
}

final class CoreDataGateway: NSObject, CoreDataGatewayType {

    // MARK: - Private properties

    private let persistentContainer: NSPersistentContainer

    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Init

    init(databaseName: String, transformers: [NSSecureUnarchiveFromDataTransformer.Type]) {
        persistentContainer = NSPersistentContainer(name: databaseName)
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        super.init()

        transformers.forEach { ValueTransformer.setValueTransformer($0.init(), forName: .init(String(describing: $0))) }
    }

    // MARK: - Internal methods

    func createManagedObject<ObjectType: NSManagedObject>() -> ObjectType {
        ObjectType(context: persistentContainer.viewContext)
    }

    func fetchData<ObjectType: CoreDataManagable>() -> [ObjectType] {
        let request = NSFetchRequest<ObjectType.ManagedObjectType>(entityName: ObjectType.ManagedObjectType.entityName)
        do {
            let entities = try persistentContainer.viewContext.fetch(request)

            return entities.map { ObjectType(managedObject: $0) }
        } catch {
            print("#ERR:", self, #function, error)
            return []
        }
    }

    func saveObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        if
            let id = object.managedObjectID,
            var managed = context.object(with: id) as? ObjectType.ManagedObjectType
        {
            managed = object.updatedManagedObject(managed)
        } else {
            var managed = ObjectType.ManagedObjectType(context: persistentContainer.viewContext)
            let managable = ObjectType(managedObject: managed)
            managed = managable.updatedManagedObject(managed)
        }
    }

    func deleteObject<ObjectType: CoreDataManagable>(_ object: ObjectType) {
        guard let id = object.managedObjectID else { return }

        context.delete(context.object(with: id))
    }

    func createFetchResultsController<ObjectType: NSManagedObject>(
        sortDescriptors: [NSSortDescriptor]
    ) -> NSFetchedResultsController<ObjectType> {
        let request = ObjectType.fetchRequest() as! NSFetchRequest<ObjectType>
        request.sortDescriptors = sortDescriptors

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        return controller
    }

    func saveChangesIfNeeded() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("#ERR: Unresolved error \(nserror), \(nserror.localizedDescription), \(nserror.userInfo)")
        }
    }

    // MARK: - Private methods

}
