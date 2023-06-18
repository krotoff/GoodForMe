//
//  ActivityListController.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import UIKit.UIViewController

import CoordinatableViewController

final class ActivityListController: CoordinatableViewController {

    // MARK: - Private types

    // MARK: - Private properties

    private let viewModel: ActivityListViewModel

    // MARK: - Init

    init(viewModel: ActivityListViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .orange
    }
}
