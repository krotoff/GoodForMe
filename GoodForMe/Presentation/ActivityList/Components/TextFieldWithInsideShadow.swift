//
//  TextFieldWithInsideShadow.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import UIKit

import ConstraintsKit
import AnimatableViewsKit

final class TextFieldWithInsideShadow: UIView {

    // MARK: - Private properties

    private let holedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
        layer.masksToBounds = true

        return layer
    }()
    private let textField: UITextField = {
        let view = UITextField()
        view.textColor = .label
        view.tintColor = .label
        view.placeholder = "Mark yourself as a Hero!"
        view.font = .systemFont(ofSize: 20, weight: .bold)
        view.borderStyle = .none
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .init(width: 0, height: 2)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.25

        return view
    }()
    private let applyButton: UIButton = {
        let button = BouncableButton()
        button.backgroundColor = .systemGreen
//        button.setImage(Asset.Images.check.image, for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .init(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.25

        return button
    }()

    // MARK: - Init

    init(backgroundColor: UIColor) {
        super.init(frame: .zero)

        holedLayer.fillColor = backgroundColor.cgColor

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.height * bounds.width > 0 else { return }

        holedLayer.frame = bounds

        let insidePath = UIBezierPath(roundedRect: .init(x: 16, y: 16, width: bounds.width - 32, height: bounds.height - 32), cornerRadius: (bounds.height - 32) / 2)
        let wholePath = UIBezierPath(rect: bounds)
        wholePath.append(insidePath.reversing())
        holedLayer.path = wholePath.cgPath

        applyButton.layer.cornerRadius = applyButton.bounds.height / 2
    }

    // MARK: - Internal methods
    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .systemBackground

        [textField, applyButton].forEach(addSubview)

        layer.addSublayer(holedLayer)

        textField
            .align(with: self, insets: .init(top: 16, left: 16 * 2, bottom: 16, right: 16 * 2))
        applyButton
            .align(with: self, edges: [.top, .right, .bottom], insets: .init(top: 24, left: 0, bottom: 24, right: 24))
            .equalsHeightToWidth()

        applyButton.transform = .init(translationX: 100, y: 0)

        textField.addTarget(self, action: #selector(textFieldValueWasChanged), for: .editingChanged)
    }

    @objc private func textFieldValueWasChanged() {
        UIView.animate(withDuration: 0.3) {
            self.applyButton.transform = (self.textField.text ?? .init()).isEmpty
            ? .init(translationX: self.applyButton.frame.width + 8, y: 0)
            : .identity
        }
    }
}
