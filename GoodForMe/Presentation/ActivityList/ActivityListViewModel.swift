//
//  ActivityListViewModel.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import Foundation.NSDate

final class ActivityListViewModel {

    // MARK: - Internal types

    enum LogicEventKind {
        case update(CollectionChangeKind)
    }

    // MARK: - Internal properties

    var model: DayPickerView.Model

    // MARK: - Private properties

    private let activityService: ActivityServiceType

    private var logicListener: ((LogicEventKind) -> Void)?

    private var dates: [Date]

    // MARK: - Init

    init(activityService: ActivityServiceType) {
        self.activityService = activityService

        let offsets = 0...365
        // TODO: Start with earliest - 31 day and end with today + 365
        let today = Date()
        dates = [Date]()
        model = .initial

        model = .init(
            models: offsets.map { index in
                let date = today.advanced(by: Double(index - 30) * 60 * 60 * 24)
                dates.append(date)
                return TrackingDayCell.Model(
                    date: date,
                    isToday: today.isSameDay(with: date),
                    state: ((index % 4) == 0) ? .normal : .finished,
                    previousDayState: (((index - 1) % 4) == 0) ? .normal : .finished,
                    nextDayState: (((index + 1) % 4) == 0) ? .normal : .finished
                )
            },
            textFieldModel: .init(
                text: nil,
                placeholder: L10n.Main.List.Textfield.placeholder,
                buttonClosure: { [weak self] name in
                    guard let name, !name.isEmpty else {
                        // TODO: Handle empty string
                        return
                    }

                    self?.createActivity(name: name)
                }
            ),
            selectedIndex: 30
        )

        activityService.fetchData()
    }

    // MARK: - Internal methods

    func subscribeForEvents(logicListener: ((LogicEventKind) -> Void)?) {
        self.logicListener = { event in DispatchQueue.main.async { logicListener?(event) } }
    }

    // MARK: - Private methods

    private func createActivity(name: String) {
        var activity = activityService.createNewActivity()
        activity.name = name
        activity.dates = [Date()]
        activityService.updateActivity(activity)
    }
}
