//
//  TestController.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 07/06/2023.
//

import UIKit

final class TestController: UIViewController {

    // MARK: - Private properties

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .init(named: "AccentColor")
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.text = "Good\nFor Me!"
        label.textAlignment = .center

        [label].forEach(view.addSubview)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
