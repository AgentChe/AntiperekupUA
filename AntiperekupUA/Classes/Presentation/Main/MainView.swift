//
//  MainView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//
import UIKit

final class MainView: UIView {
    
    lazy var segmentView = makeSegmentControl()
    lazy var tableView = makeTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainView {
    func initialize() {
        backgroundColor = .white
        segmentView.segments = [
            makeSegment(name: "tab_reg_number".localized),
            makeSegment(name: "tab_vin_number".localized),
            makeSegment(name: "technical_passport".localized)
        ]
    }
}

// MARK: Make constraints
private extension MainView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            segmentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale),
            segmentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            segmentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            segmentView.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentView.bottomAnchor, constant: 16.scale),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MainView {
    func makeSegmentControl() -> MainSegmentControlView {
        let view = MainSegmentControlView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSegment(name: String) -> MainSegmentItem {
        let view = MainSegmentItem()
        
        view.setAttributedTitle(name.attributed(with: .initial), for: .normal)
        view.setAttributedTitle(name.attributed(with: .selected), for: .selected)
        return view
    }
    
    func makeTableView() -> MainTableView {
        let view = MainTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let initial = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 13.scale))
        .lineHeight(15.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
    
    static let selected = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 13.scale))
        .lineHeight(15.scale)
        .textColor(.white)
}
