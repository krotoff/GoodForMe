//
//  ActivityListCoordinator.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 17/06/2023.
//

import CoordinatorKit
import CoordinatableViewController

final class ActivityListCoordinator: Coordinator {

    // MARK: - Private properties

    private let activityService: ActivityServiceType

    // MARK: - Init

    init(parentCoordinator: BaseCoordinator, activityService: ActivityServiceType) {
        self.activityService = activityService

        super.init(parentCoordinator: parentCoordinator)
    }

    override func makeController() -> CoordinatableViewController {
        let viewModel = ActivityListViewModel() 
        return ActivityListController(viewModel: viewModel)
    }

    // MARK: - Private methods
}
