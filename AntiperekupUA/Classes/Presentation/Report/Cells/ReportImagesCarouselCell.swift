//
//  ReportImagesCarouselCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//
import UIKit

final class ReportImagesCarouselCell: UITableViewCell {
    
    private lazy var carouselView = makeCollectionView()
    private lazy var separator = makeSeparator()
    private lazy var titleLabel = makeTitle()
    private lazy var valueLabel = makeValue()
    lazy var containerView = makeContainer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scroll(to index: Int) {
        carouselView.scroll(to: index)
    }
}

extension ReportImagesCarouselCell {
    func setup(for elements: [URL], didSelectItem: @escaping (_ elements: [URL], _ index: Int) -> Void) {
        carouselView.setup(elements: elements, didSelectItem: didSelectItem)
        valueLabel.attributedText = "\(elements.count)".attributed(with: .value)
    }
}

extension ReportImagesCarouselCell: CornerCellContainer {}

private extension ReportImagesCarouselCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportImagesCarouselCell {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.scale),
            valueLabel.heightAnchor.constraint(equalToConstant: 24.scale),
            valueLabel.widthAnchor.constraint(equalTo: valueLabel.heightAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8.scale),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            carouselView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 6.scale),
            carouselView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            carouselView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            carouselView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportImagesCarouselCell {
    func makeCollectionView() -> ReportImageCarouselView {
        let view = ReportImageCarouselView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        containerView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.attributedText = "photos_title".localized.attributed(with: .title)
        containerView.addSubview(view)
        return view
    }
    
    func makeValue() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 69, green: 142, blue: 156)
        view.layer.cornerRadius = 12.scale
        view.clipsToBounds = true
        containerView.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 246, green: 246, blue: 247)
        containerView.addSubview(view)
        return view
    }
    
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 12.scale))
        .textColor(.black)
        .textAlignment(.left)
    
    static let value = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(.white)
        .textAlignment(.center)
}
