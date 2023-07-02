//
//  DayPickerView.swift
//  GoodForMe
//
//  Created by Andrei Krotov on 18/06/2023.
//

import UIKit

import ConstraintsKit

final class DayPickerView: UIView {

    // MARK: - Internal types

    struct Model: Equatable {
        let models: [TrackingDayCell.Model]
        let textFieldModel: TextFieldWithInsideShadow.Model
        var selectedIndex: Int

        static let initial = Model(models: [], textFieldModel: .initial, selectedIndex: 0)
    }

    private struct Constants {
        static let cellWidth: CGFloat = 44
        static let textFieldHeight: CGFloat = 80
    }

    // MARK: - Private properties

    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    private let textField = TextFieldWithInsideShadow(backgroundColor: .secondarySystemBackground)

    private let selectorLayer = CAShapeLayer()
    private var model = Model.initial
    private var wasSet = false

    private var lastCellToScroll: Int?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        lastCellToScroll = nil
        drawSelectorIfNeeded()
    }

    // MARK: - Internal methods

    func configure(with model: Model) {
        guard self.model != model else { return }

        self.model = model
        textField.configure(model: model.textFieldModel)
        collectionView.reloadData()
        wasSet = false
    }

    // MARK: - Private methods

    private func setupUI() {
        [collectionView, textField].forEach(addSubview)
        [selectorLayer].forEach(collectionView.layer.addSublayer)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackingDayCell.self, forCellWithReuseIdentifier: TrackingDayCell.reuseIdentifier)
        collectionView.canCancelContentTouches = false
        collectionView.clipsToBounds = false

        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0

        collectionView
            .align(with: self, edges: [.left, .right, .top])
        textField
            .align(with: self, edges: [.left, .right, .bottom])
            .spacingToBottom(of: collectionView, constant: 8)
            .equalsHeight(to: Constants.textFieldHeight)

        selectorLayer.opacity = 0
        selectorLayer.zPosition = -1
    }

    private func placeSelector() {
        guard lastCellToScroll != model.selectedIndex + 1 else { return }

        collectionView.scrollToItem(
            at: IndexPath(item: model.selectedIndex + 1, section: 0), at: .right, animated: lastCellToScroll != nil
        )

        guard let cell = collectionView.cellForItem(at: IndexPath(item: model.selectedIndex, section: 0)) else { return }

        lastCellToScroll = model.selectedIndex + 1
        let x = cell.frame.midX - selectorLayer.frame.width / 2
        if selectorLayer.opacity == 0 {
            selectorLayer.frame.origin = .init(x: x, y: selectorLayer.frame.origin.y)
            UIView.animate(withDuration: 0.3) {
                self.selectorLayer.opacity = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.selectorLayer.frame.origin = .init(x: x, y: self.selectorLayer.frame.origin.y)
            }
        }
    }

    private func drawSelectorIfNeeded() {
        guard collectionView.contentSize.width * collectionView.contentSize.height > 0 else { return }

        defer { placeSelector() }

        guard
            !wasSet,
            collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) != nil
        else { return }

        wasSet = true

        let radius = Constants.cellWidth / 2
        let width = collectionView.contentSize.width

        let path = UIBezierPath()
        path.move(to: .init(x: -width, y: -frame.height * 2))
        path.addLine(to: .init(x: width, y: -frame.height * 2))
        path.addLine(to: .init(x: width, y: frame.height - 88))
        path.addLine(to: .init(x: Constants.cellWidth, y: frame.height - 88))
        path.addArc(
            withCenter: .init(x: Constants.cellWidth, y: frame.height - radius - 88),
            radius: radius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: .init(x: Constants.cellWidth / 2, y: radius))
        path.addArc(
            withCenter: .init(x: 0, y: radius),
            radius: radius,
            startAngle: 0,
            endAngle: .pi,
            clockwise: false
        )
        path.addLine(to: .init(x: -radius, y: frame.height - radius - 88))
        path.addArc(
            withCenter: .init(x: -Constants.cellWidth, y: frame.height - radius - 88),
            radius: radius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: .init(x: -width, y: frame.height - 88))
        path.addLine(to: .init(x: -width, y: -frame.height * 2))
        path.close()

        selectorLayer.path = path.cgPath
        selectorLayer.fillColor = UIColor.tertiarySystemGroupedBackground.cgColor
        selectorLayer.shadowColor = UIColor.black.cgColor
        selectorLayer.shadowRadius = 5
        selectorLayer.shadowOffset = .init(width: 0, height: 3)
        selectorLayer.shadowOpacity = 0.5
    }
}

extension DayPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: TrackingDayCell.reuseIdentifier, for: indexPath)
    }
}

extension DayPickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 44, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TrackingDayCell else { return }

        cell.configure(with: model.models[indexPath.item])
        drawSelectorIfNeeded()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        model.selectedIndex = indexPath.item
        placeSelector()
    }
}



public extension UICollectionReusableView {

    // MARK: - Public properties

    static var reuseIdentifier: String { return String(describing: self) }
    static var bundle: Bundle { return Bundle(for: Self.self) }

    // MARK: - Public methods

    func gestureRecognizerShouldBeginForSwipableCell(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = recognizer.velocity(in: self)
            return abs(velocity.y) < abs(velocity.x)
        }

        return true
    }
}
