//
//  CheckResultValueView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 19.09.2021.
//
import UIKit

final class CheckResultValueView: UIView {
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var valueLabel = makeValueLabel()
    private lazy var separator = makeSeparator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckResultValueView {
    func setup(for title: String, value: String, isShowSeparator: Bool = true) {
        titleLabel.attributedText = title.attributed(with: .title)
        valueLabel.attributedText = value.attributed(with: .value)
        separator.isHidden = !isShowSeparator
    }
}

// MARK: Make constraints
private extension CheckResultValueView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8.scale),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CheckResultValueView {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 246, green: 246, blue: 247)
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 12.scale))
        .lineHeight(14.scale)
        .textColor(UIColor(integralRed: 60, green: 60, blue: 67, alpha: 0.6))
    
    static let value = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 17.scale))
        .lineHeight(22.scale)
        .textColor(.black)
}


#if DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct CheckResultValueView_Previews: PreviewProvider {
    
    struct CheckResultValueRepresentable: UIViewRepresentable {
        func makeUIView(context: Context) -> CheckResultValueView {
            let view = CheckResultValueView()
            return view
        }
        func updateUIView(_ uiView: CheckResultValueView, context: Context) {
            
        }
    }

    static var previews: some View {
        return CheckResultValueRepresentable().frame(width: 343, height: 165, alignment: .center)
    }
}
#endif
