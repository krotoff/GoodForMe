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

        let ttt = 0...365
        let today = Date()
        dayPickerView.configure(with: DayPickerView.Model(
            models: ttt.map { index in
                let date = today.advanced(by: Double(index - 7) * 60 * 60 * 24)
                return TrackingDayCell.Model(
                    date: date,
                    isToday: today.isSameDay(with: date),
                    state: ((index % 4) == 0) ? .normal : .finished,
                    previousDayState: (((index - 1) % 4) == 0) ? .normal : .finished,
                    nextDayState: (((index + 1) % 4) == 0) ? .normal : .finished
                )
            },
            selectedIndex: 0
        ))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedAnywhere() {
        view.endEditing(true)
    }
}
