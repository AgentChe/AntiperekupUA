//
//  ReportFooterView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.11.2021.
//
import UIKit

final class ReportFooterView: UIView {
    
    lazy var shareReportButton = makeReportButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ReportFooterView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            shareReportButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 21.scale),
            shareReportButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            shareReportButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            shareReportButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            shareReportButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportFooterView {
    func makeReportButton() -> BottomButtonView {
        let view = BottomButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(title: "share_report".localized.uppercased(), isHiddenBottomLine: false)
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let button = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 20.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 40, green: 42, blue: 48))
}
