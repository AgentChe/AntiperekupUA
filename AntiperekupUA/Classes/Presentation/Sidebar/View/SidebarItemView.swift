//
//  SidebarItemView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.10.2021.
//
import UIKit

final class SidebarItemView: UIView {
    
    private lazy var iconView = makeIconView()
    private lazy var stackView = makeStackView()
    private lazy var titleLabel = makeLabel()
    private lazy var subtitleLabel = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SidebarItemView {
    func setup(for icon: UIImage?, title: String, subtitle: String? = nil) {
        iconView.image = icon
        titleLabel.attributedText = title.attributed(with: .title)
        if let subtitle = subtitle {
            subtitleLabel.attributedText = subtitle.attributed(with: .subtitle)
            subtitleLabel.isHidden = false
        }
    }
}

private extension SidebarItemView {
    func initialize() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.isHidden = true
        backgroundColor = .clear
    }
}

// MARK: Make constraints
private extension SidebarItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 22.scale),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SidebarItemView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 3.scale
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 13.scale))
        .textColor(.black)
        .lineHeight(28.scale)
        .textAlignment(.left)
    
    static let subtitle = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 13.scale))
        .textColor(.black)
        .textAlignment(.left)
}


#if DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct SidebarItemView_Previews: PreviewProvider {
    
    struct SidebarItemRepresentable: UIViewRepresentable {
        func makeUIView(context: Context) -> SidebarItemView {
            let view = SidebarItemView()
            view.setup(for: UIImage(named: "Sidebar.Police"), title: "Политика конфиденциальности", subtitle: "2C7EF22B9EED48AC")
            return view
        }
        func updateUIView(_ uiView: SidebarItemView, context: Context) {
            
        }
    }

    static var previews: some View {
        return SidebarItemRepresentable().frame(width: 314, height: 28, alignment: .center)
    }
}
#endif
