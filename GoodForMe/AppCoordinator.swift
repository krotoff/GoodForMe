//
//  AppCoordinator.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 17/06/2023.
//

import UIKit.UIWindow

import CoordinatorKit

final class AppCoordinator: BaseCoordinator {

    // MARK: - Private properties

    private let window: UIWindow

    private let coreDataGateway = CoreDataGateway(
        databaseName: "GoodForMe",
        transformers: [SecureUnarchiveFromDataTransformer.self]
    )

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window

        super.init()
    }

    // MARK: - Internal methods

    func startApp() {
        let coordinator = ActivityListCoordinator(
            parentCoordinator: self,
            activityService: ActivityService(dataGateway: coreDataGateway)
        )

        setControllerAsRoot(coordinator.controller)
    }

    func resignActive() {
        coreDataGateway.saveChangesIfNeeded()
    }

    // MARK: - Private methods

    private func setControllerAsRoot(_ controller: UIViewController) {
        window.rootViewController = controller
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: nil)
        window.makeKeyAndVisible()
    }
}
