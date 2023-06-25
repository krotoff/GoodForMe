//
//  ActivityService.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import Foundation.NSDate
import CoreData

public protocol ActivityServiceType {
    var activities: [UserActivity] { get }

    func fetchData()
    func updateActivity(_ activity: UserActivity)
    func createNewActivity() -> UserActivity
    func deleteActivity(_ id: String)
    func subscribeOnChanges(id: String, completion: ((CollectionChangeKind) -> Void)?)
    func unsubscribeFromChanges(id: String)
}

final class ActivityService: NSObject, ActivityServiceType {

    // MARK: - Internal properties

    var activities = [UserActivity]()

    // MARK: - Private properties

    private let dataGateway: CoreDataGatewayType
    private var subscribes = [String: ((CollectionChangeKind) -> Void)?]()
    private let fetchController: NSFetchedResultsController<UserActivity.ManagedObjectType>

    // MARK: - Init

    init(dataGateway: CoreDataGatewayType) {
        self.dataGateway = dataGateway
        fetchController = dataGateway.createFetchResultsController(sortDescriptors: [])

        super.init()

        fetchController.delegate = self
    }

    // MARK: - Internal methods

    func fetchData() {
        do {
            try fetchController.performFetch()
            activities = fetchController.fetchedObjects?.map(UserActivity.init) ?? []
        } catch {
            print(error)
        }
    }

    func updateActivity(_ activity: UserActivity) {
        dataGateway.saveObject(activity)
    }

    func createNewActivity() -> UserActivity {
        UserActivity(managedObject: dataGateway.createManagedObject())
    }

    func deleteActivity(_ id: String) {
        guard let index = activities.firstIndex(where: { $0.id == id }) else { return }

        dataGateway.deleteObject(activities[index])
    }

    func subscribeOnChanges(id: String, completion: ((CollectionChangeKind) -> Void)?) {
        subscribes[id] = completion
    }

    func unsubscribeFromChanges(id: String) {
        subscribes[id] = nil
    }

    // MARK: - Private methods
}

extension ActivityService: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        activities = fetchController.fetchedObjects?.map(UserActivity.init) ?? []
        switch type {
        case .insert:
            subscribes.values.forEach { $0?(.insert(newIndexPath!)) }
        case .delete:
            subscribes.values.forEach { $0?(.delete(indexPath!)) }
        case .update:
            subscribes.values.forEach { $0?(.update(indexPath!)) }
        case .move:
            subscribes.values.forEach { $0?(.move(from: indexPath!, to: newIndexPath!)) }
        }
    }
}
