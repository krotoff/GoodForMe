//
//  ActivityListController.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import UIKit.UIViewController

import CoordinatableViewController
import ConstraintsKit

final class ActivityListController: CoordinatableViewController {

    // MARK: - Private types

    // MARK: - Private properties

    private let viewModel: ActivityListViewModel

    private let dayPickerView = DayPickerView()

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
        view.addSubview(dayPickerView)

        view.backgroundColor = .secondarySystemBackground

        dayPickerView
            .align(with: view, edges: [.left, .right, .top], isInSafeArea: true)
            .equalsHeight(to: 152)

        dayPickerView.configure(with: viewModel.model)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedAnywhere() {
        view.endEditing(true)
    }
}
